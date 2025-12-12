<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated',
            ], 401);
        }

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
                'category_id' => $user->category_id,
                'membership_code' => $user->membership_code,
                'avatar' => $user->avatar,
            ],
            'message' => 'Profile retrieved successfully',
        ]);
    }

    public function update(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated',
                ], 401);
            }

            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => 'sometimes|email|unique:users,email,' . $user->id,
                'phone' => 'sometimes|string|max:20',
                'governorate' => 'sometimes|string|max:255',
                'city' => 'sometimes|string|max:255',
                'district' => 'sometimes|string|max:255',
                'password' => 'sometimes|string|min:6',
                'profile_image' => 'sometimes|string', // Base64 encoded image
                'image_type' => 'sometimes|string|in:base64,file',
            ]);

            // Update basic fields
            if (isset($validated['name'])) {
                $user->name = $validated['name'];
            }
            if (isset($validated['email'])) {
                $user->email = $validated['email'];
            }
            if (isset($validated['phone'])) {
                $user->phone = $validated['phone'];
            }
            if (isset($validated['governorate'])) {
                $user->governorate = $validated['governorate'];
            }
            if (isset($validated['city'])) {
                $user->city = $validated['city'];
            }
            if (isset($validated['district'])) {
                $user->district = $validated['district'];
            }
            if (isset($validated['password'])) {
                $user->password = bcrypt($validated['password']);
            }

            // Handle profile image upload
            if (isset($validated['profile_image']) && isset($validated['image_type'])) {
                try {
                    $avatarUrl = null;

                    if ($validated['image_type'] === 'base64') {
                        // Decode base64 image
                        $imageData = $validated['profile_image'];
                        
                        // Remove data URL prefix if present
                        if (preg_match('/^data:image\/(\w+);base64,/', $imageData, $matches)) {
                            $imageData = preg_replace('/^data:image\/\w+;base64,/', '', $imageData);
                        }

                        $decodedImage = base64_decode($imageData);
                        
                        if ($decodedImage === false) {
                            throw new \Exception('Invalid base64 image data');
                        }

                        // Generate unique filename
                        $filename = 'avatars/' . $user->id . '_' . time() . '.png';
                        
                        // Save to public storage
                        Storage::disk('public')->put($filename, $decodedImage);
                        
                        // Get public URL
                        $avatarUrl = Storage::disk('public')->url($filename);
                        
                        Log::info('Profile image uploaded', [
                            'user_id' => $user->id,
                            'filename' => $filename,
                            'url' => $avatarUrl,
                        ]);
                    }

                    if ($avatarUrl) {
                        // Delete old avatar if exists
                        if ($user->avatar) {
                            $oldPath = str_replace(Storage::disk('public')->url(''), '', $user->avatar);
                            if (Storage::disk('public')->exists($oldPath)) {
                                Storage::disk('public')->delete($oldPath);
                            }
                        }
                        
                        $user->avatar = $avatarUrl;
                    }
                } catch (\Exception $e) {
                    Log::error('Error uploading profile image', [
                        'user_id' => $user->id,
                        'error' => $e->getMessage(),
                    ]);
                    
                    return response()->json([
                        'success' => false,
                        'message' => 'فشل رفع الصورة: ' . $e->getMessage(),
                    ], 400);
                }
            }

            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث البيانات بنجاح',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'avatar' => $user->avatar,
                ],
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'خطأ في البيانات المدخلة',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error updating user profile', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث البيانات',
            ], 500);
        }
    }
}
