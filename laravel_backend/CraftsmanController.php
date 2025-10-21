<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CraftsmanController extends Controller
{
    public function count(Request $request)
    {
        $category_id = $request->get('category_id', 1);

        try {
            $count = DB::table('users')
                ->where('user_type', 'craftsman')
                ->where('status', 'active')
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'category_id' => $category_id,
                    'count' => $count
                ],
                'message' => 'Craftsman count retrieved successfully'
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
