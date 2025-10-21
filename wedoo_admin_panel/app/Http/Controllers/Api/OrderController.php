<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\User;
use App\Models\TaskType;

class OrderController extends Controller
{
    public function create(Request $request)
    {
        $validated = $request->validate([
            'customer_id' => 'required|exists:users,id',
            'task_type_id' => 'required|exists:task_types,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'governorate' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:255',
            'district' => 'nullable|string|max:255',
            'budget' => 'nullable|numeric',
            'preferred_date' => 'nullable|date',
            'notes' => 'nullable|string'
        ]);

        $order = Order::create($validated);

        return response()->json([
            'success' => true,
            'data' => $order,
            'message' => 'Order created successfully'
        ]);
    }

    public function list(Request $request)
    {
        $userId = $request->get('user_id');
        $orders = Order::with(['customer', 'craftsman', 'taskType'])
            ->when($userId, function ($query) use ($userId) {
                return $query->where('customer_id', $userId);
            })
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'customer_id' => $order->customer_id,
                    'customer_name' => $order->customer->name,
                    'craftsman_id' => $order->craftsman_id,
                    'craftsman_name' => $order->craftsman ? $order->craftsman->name : null,
                    'task_type_id' => $order->task_type_id,
                    'task_type_name' => $order->taskType->name,
                    'title' => $order->title,
                    'description' => $order->description,
                    'location' => $order->location,
                    'governorate' => $order->governorate,
                    'city' => $order->city,
                    'district' => $order->district,
                    'budget' => $order->budget,
                    'preferred_date' => $order->preferred_date,
                    'status' => $order->status,
                    'notes' => $order->notes,
                    'created_at' => $order->created_at->format('Y-m-d H:i:s')
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $orders,
            'message' => 'Orders retrieved successfully'
        ]);
    }
}
