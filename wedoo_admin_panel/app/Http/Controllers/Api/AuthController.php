<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required',
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'user_type' => $user->user_type,
                'status' => $user->status,
                'governorate' => $user->governorate,
                'city' => $user->city,
                'district' => $user->district,
                'membership_code' => $user->membership_code ?? '',
                'category_id' => $user->category_id,
                'access_token' => $token,
                'refresh_token' => $token, // Using same token for refresh
            ],
            'message' => 'Login successful'
        ]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'phone' => 'required|string|max:255|unique:users,phone',
            'user_type' => 'required|in:customer,craftsman',
            'category_id' => 'nullable|exists:categories,id',
            'task_type_ids' => 'nullable|array',
            'task_type_ids.*' => 'exists:task_types,id',
            'governorate' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:255',
            'district' => 'nullable|string|max:255',
        ], [
            'phone.required' => 'رقم الهاتف مطلوب',
            'phone.unique' => 'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم آخر',
            'task_type_ids.array' => 'يجب أن تكون المهام مصفوفة',
            'task_type_ids.*.exists' => 'إحدى المهام المختارة غير موجودة',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'user_type' => $request->user_type,
            'status' => 'active',
            'category_id' => $request->category_id,
            'governorate' => $request->governorate,
            'city' => $request->city,
            'district' => $request->district,
        ]);

        // Attach task types to craftsman if provided
        if ($request->user_type === 'craftsman' && $request->has('task_type_ids') && is_array($request->task_type_ids)) {
            $taskTypeIds = array_filter($request->task_type_ids, function($id) {
                return is_numeric($id);
            });
            
            if (!empty($taskTypeIds)) {
                // Verify all task types belong to the selected category
                $validTaskTypes = \App\Models\TaskType::where('category_id', $request->category_id)
                    ->whereIn('id', $taskTypeIds)
                    ->pluck('id')
                    ->toArray();
                
                if (!empty($validTaskTypes)) {
                    $user->taskTypes()->sync($validTaskTypes);
                }
            }
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'user_type' => $user->user_type,
                    'status' => $user->status,
                    'governorate' => $user->governorate,
                    'city' => $user->city,
                    'district' => $user->district,
                    'category_id' => $user->category_id,
                ],
                'access_token' => $token,
                'token_type' => 'Bearer'
            ],
            'message' => 'Registration successful'
        ], 201);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        // Find user by email
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني'
            ], 404);
        }

        // Generate 6-digit code
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Delete any existing tokens for this email
        \App\Models\PasswordResetToken::where('email', $request->email)->delete();

        // Create new token
        \App\Models\PasswordResetToken::create([
            'email' => $request->email,
            'token' => $code,
            'expires_at' => now()->addMinutes(15), // Token expires in 15 minutes
        ]);

        // Send email with code using Brevo
        try {
            \Illuminate\Support\Facades\Mail::to($request->email)
                ->send(new \App\Mail\PasswordResetMail($code, $request->email));
            
            \Illuminate\Support\Facades\Log::info('Password reset email sent successfully', [
                'email' => $request->email,
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Failed to send password reset email', [
                'email' => $request->email,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            // Return error if email sending fails
            return response()->json([
                'success' => false,
                'message' => 'فشل إرسال الإيميل. يرجى المحاولة مرة أخرى لاحقاً.',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
            'data' => [
                'email' => $request->email,
                // For testing purposes only - remove in production
                'code' => config('app.debug') ? $code : null,
            ]
        ]);
    }

    public function verifyResetCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6',
        ]);

        // Find token
        $resetToken = \App\Models\PasswordResetToken::where('email', $request->email)
            ->where('token', $request->code)
            ->first();

        if (!$resetToken) {
            return response()->json([
                'success' => false,
                'message' => 'رمز التحقق غير صحيح'
            ], 400);
        }

        // Check if token is expired
        if ($resetToken->expires_at < now()) {
            $resetToken->delete();
            return response()->json([
                'success' => false,
                'message' => 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد'
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'رمز التحقق صحيح',
            'data' => [
                'email' => $request->email,
                'verified' => true,
            ]
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        // Find token
        $resetToken = \App\Models\PasswordResetToken::where('email', $request->email)
            ->where('token', $request->code)
            ->first();

        if (!$resetToken) {
            return response()->json([
                'success' => false,
                'message' => 'رمز التحقق غير صحيح'
            ], 400);
        }

        // Check if token is expired
        if ($resetToken->expires_at < now()) {
            $resetToken->delete();
            return response()->json([
                'success' => false,
                'message' => 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد'
            ], 400);
        }

        // Find user and update password
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود'
            ], 404);
        }

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        // Delete the used token
        $resetToken->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث كلمة المرور بنجاح',
            'data' => [
                'email' => $user->email,
            ]
        ]);
    }
}
