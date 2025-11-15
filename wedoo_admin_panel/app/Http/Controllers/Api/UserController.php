<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

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
            ],
            'message' => 'Profile retrieved successfully',
        ]);
    }
}
