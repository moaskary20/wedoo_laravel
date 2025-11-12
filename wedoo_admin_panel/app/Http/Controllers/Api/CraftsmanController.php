<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class CraftsmanController extends Controller
{
    public function count(Request $request)
    {
        // Build query for active craftsmen
        $query = User::where('user_type', 'craftsman')
            ->where('status', 'active');

        // Filter by category_id if provided
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        $count = $query->count();

        return response()->json([
            'success' => true,
            'data' => ['count' => $count],
            'message' => 'Craftsman count retrieved successfully'
        ]);
    }
}
