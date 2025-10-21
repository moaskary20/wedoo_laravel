<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function create(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer',
            'task_type_id' => 'required|integer',
            'description' => 'required|string',
            'location' => 'required|string',
            'phone' => 'required|string',
        ]);

        try {
            $orderId = DB::table('orders')->insertGetId([
                'user_id' => $request->user_id,
                'task_type_id' => $request->task_type_id,
                'description' => $request->description,
                'location' => $request->location,
                'phone' => $request->phone,
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Get order details with task information
            $order = DB::table('orders')
                ->leftJoin('task_types', 'orders.task_type_id', '=', 'task_types.id')
                ->where('orders.id', $orderId)
                ->select(
                    'orders.id',
                    'orders.user_id',
                    'orders.task_type_id',
                    'task_types.name as task_name',
                    'task_types.price_range',
                    'task_types.duration',
                    'orders.description',
                    'orders.location',
                    'orders.phone',
                    'orders.status',
                    'orders.created_at'
                )
                ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $order->id,
                    'user_id' => $order->user_id,
                    'task_type_id' => $order->task_type_id,
                    'task_name' => $order->task_name,
                    'description' => $order->description,
                    'location' => $order->location,
                    'phone' => $order->phone,
                    'status' => $order->status,
                    'created_at' => $order->created_at,
                    'estimated_price' => $order->price_range,
                    'estimated_duration' => $order->duration
                ],
                'message' => 'Order created successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Database error: ' . $e->getMessage(),
                'error_code' => 'DATABASE_ERROR'
            ]);
        }
    }

    public function list(Request $request)
    {
        $user_id = $request->get('user_id', 1);

        try {
            $orders = DB::table('orders')
                ->leftJoin('task_types', 'orders.task_type_id', '=', 'task_types.id')
                ->where('orders.user_id', $user_id)
                ->orderBy('orders.created_at', 'desc')
                ->select(
                    'orders.id',
                    'orders.user_id',
                    'orders.task_type_id',
                    'task_types.name as task_name',
                    'task_types.price_range',
                    'task_types.duration',
                    'orders.description',
                    'orders.location',
                    'orders.phone',
                    'orders.status',
                    'orders.created_at'
                )
                ->get();

            // Format the response
            $formatted_orders = $orders->map(function ($order) {
                return [
                    'id' => $order->id,
                    'user_id' => $order->user_id,
                    'task_type_id' => $order->task_type_id,
                    'task_name' => $order->task_name,
                    'description' => $order->description,
                    'location' => $order->location,
                    'phone' => $order->phone,
                    'status' => $order->status,
                    'created_at' => $order->created_at,
                    'estimated_price' => $order->price_range,
                    'estimated_duration' => $order->duration
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $formatted_orders,
                'message' => 'Orders retrieved successfully'
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
