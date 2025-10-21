<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class CraftsmanController extends Controller
{
    public function count()
    {
        $count = User::where('user_type', 'craftsman')
            ->where('status', 'active')
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['count' => $count],
            'message' => 'Craftsman count retrieved successfully'
        ]);
    }
}
