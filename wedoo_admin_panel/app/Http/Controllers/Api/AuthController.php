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
            'governorate' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:255',
            'district' => 'nullable|string|max:255',
        ], [
            'phone.required' => 'رقم الهاتف مطلوب',
            'phone.unique' => 'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم آخر',
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

        // Send email with code
        try {
            \Illuminate\Support\Facades\Mail::raw(
                "رمز استعادة كلمة المرور الخاص بك هو: {$code}\n\nهذا الرمز صالح لمدة 15 دقيقة.",
                function ($message) use ($request) {
                    $message->to($request->email)
                            ->subject('رمز استعادة كلمة المرور - WeDoo');
                }
            );
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Failed to send password reset email: ' . $e->getMessage());
            // Continue anyway - code is saved in database
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
