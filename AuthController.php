<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        try {
            $user = DB::table('users')
                ->where('phone', $request->phone)
                ->where('password', $request->password)
                ->where('status', 'active')
                ->first();

            if ($user) {
                // Generate tokens
                $access_token = 'token_' . uniqid() . '_' . time();
                $refresh_token = 'refresh_' . uniqid() . '_' . time();

                return response()->json([
                    'success' => true,
                    'data' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'phone' => $user->phone,
                        'email' => $user->email,
                        'user_type' => $user->user_type,
                        'governorate' => $user->governorate,
                        'city' => $user->city,
                        'district' => $user->district,
                        'membership_code' => $user->membership_code,
                        'access_token' => $access_token,
                        'refresh_token' => $refresh_token,
                        'login_time' => now()->format('Y-m-d H:i:s'),
                    ],
                    'message' => 'Login successful',
                    'timestamp' => time()
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid phone number or password',
                    'error_code' => 'INVALID_CREDENTIALS'
                ]);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Database error: ' . $e->getMessage(),
                'error_code' => 'DATABASE_ERROR'
            ]);
        }
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'user_type' => 'required|in:customer,craftsman',
            'governorate' => 'required|string',
            'city' => 'required|string',
            'district' => 'required|string',
        ]);

        try {
            // Check if user already exists
            $existingUser = DB::table('users')
                ->where('phone', $request->phone)
                ->orWhere('email', $request->email)
                ->first();

            if ($existingUser) {
                return response()->json([
                    'success' => false,
                    'message' => 'User with this phone number or email already exists',
                    'error_code' => 'USER_EXISTS'
                ]);
            }

            // Generate unique membership code
            $membership_code = 'WED' . rand(100000, 999999);
            
            // Check if membership code already exists
            while (DB::table('users')->where('membership_code', $membership_code)->exists()) {
                $membership_code = 'WED' . rand(100000, 999999);
            }

            // Insert new user
            $userId = DB::table('users')->insertGetId([
                'name' => $request->name,
                'phone' => $request->phone,
                'email' => $request->email,
                'password' => $request->password,
                'user_type' => $request->user_type,
                'governorate' => $request->governorate,
                'city' => $request->city,
                'district' => $request->district,
                'membership_code' => $membership_code,
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Get the inserted user data
            $user = DB::table('users')->where('id', $userId)->first();

            // Generate tokens
            $access_token = 'token_' . uniqid() . '_' . time();
            $refresh_token = 'refresh_' . uniqid() . '_' . time();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'phone' => $user->phone,
                    'email' => $user->email,
                    'user_type' => $user->user_type,
                    'governorate' => $user->governorate,
                    'city' => $user->city,
                    'district' => $user->district,
                    'membership_code' => $user->membership_code,
                    'access_token' => $access_token,
                    'refresh_token' => $refresh_token,
                    'created_at' => $user->created_at,
                    'status' => $user->status
                ],
                'message' => 'User registered successfully',
                'timestamp' => time()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Database error: ' . $e->getMessage(),
                'error_code' => 'DATABASE_ERROR'
            ]);
        }
    }
}
