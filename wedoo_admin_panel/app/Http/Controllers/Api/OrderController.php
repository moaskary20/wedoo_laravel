<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\User;
use App\Models\Chat;
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
            'notes' => 'nullable|string',
            'images' => 'nullable|array',
            'images.*' => 'nullable|string' // Accept both URLs and base64 data URLs
        ]);

        $validated['status'] = $validated['status'] ?? 'pending';
        $validated['craftsman_status'] = 'awaiting_assignment';

        // Handle image uploads if provided
        $imageUrls = [];
        if ($request->hasFile('images')) {
            $uploadedImages = $request->file('images');
            foreach ($uploadedImages as $image) {
                if ($image->isValid()) {
                    $path = $image->store('orders/images', 'public');
                    $imageUrls[] = asset('storage/' . $path);
                }
            }
        } elseif ($request->has('images') && is_array($request->images)) {
            // If images are sent as base64 data URLs
            foreach ($request->images as $imageData) {
                if (is_string($imageData) && strpos($imageData, 'data:image') === 0) {
                    // Extract base64 data
                    $base64Data = explode(',', $imageData)[1] ?? '';
                    $imageData = base64_decode($base64Data);
                    
                    if ($imageData) {
                        // Generate unique filename
                        $filename = 'order_' . time() . '_' . uniqid() . '.jpg';
                        $path = 'orders/images/' . $filename;
                        $fullPath = storage_path('app/public/' . $path);
                        
                        // Create directory if it doesn't exist
                        $directory = dirname($fullPath);
                        if (!is_dir($directory)) {
                            mkdir($directory, 0755, true);
                        }
                        
                        // Save image
                        file_put_contents($fullPath, $imageData);
                        $imageUrls[] = asset('storage/' . $path);
                    }
                } elseif (is_string($imageData) && filter_var($imageData, FILTER_VALIDATE_URL)) {
                    // If it's already a URL, use it directly
                    $imageUrls[] = $imageData;
                }
            }
        }

        if (!empty($imageUrls)) {
            $validated['images'] = $imageUrls;
        }

        $order = Order::create($validated);

        return response()->json([
            'success' => true,
            'data' => $this->transformOrder($order),
            'message' => 'Order created successfully'
        ]);
    }

    public function list(Request $request)
    {
        $userId = $request->get('user_id');
        $craftsmanId = $request->get('craftsman_id');
        $status = $request->get('status');
        $craftsmanStatus = $request->get('craftsman_status');

        $orders = Order::with(['customer', 'craftsman', 'taskType'])
            ->when($userId, function ($query) use ($userId) {
                return $query->where('customer_id', $userId);
            })
            ->when($craftsmanId, function ($query) use ($craftsmanId) {
                return $query->where('craftsman_id', $craftsmanId);
            })
            ->when($status, function ($query) use ($status) {
                return $query->where('status', $status);
            })
            ->when($craftsmanStatus, function ($query) use ($craftsmanStatus) {
                return $query->where('craftsman_status', $craftsmanStatus);
            })
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($order) => $this->transformOrder($order));

        return response()->json([
            'success' => true,
            'data' => $orders,
            'message' => 'Orders retrieved successfully'
        ]);
    }

    public function assigned(Request $request)
    {
        $user = $request->user();
        if (!$user || $user->user_type !== 'craftsman') {
            return response()->json([
                'success' => false,
                'message' => 'Only craftsmen can access assigned orders',
            ], 403);
        }

        // Get craftsman's task type IDs
        $craftsmanTaskTypeIds = $user->taskTypes()->pluck('task_types.id')->toArray();
        
        // Get orders assigned to this craftsman
        $assignedOrders = Order::with(['customer', 'taskType'])
            ->where('craftsman_id', $user->id)
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($order) => $this->transformOrder($order));

        // Get available orders matching craftsman's task types
        // Only show orders that match the craftsman's selected task types
        $availableOrders = Order::with(['customer', 'taskType'])
            ->where('status', 'pending')
            ->where('craftsman_status', 'awaiting_assignment')
            ->whereNull('craftsman_id') // Not assigned yet
            ->when(!empty($craftsmanTaskTypeIds), function ($query) use ($craftsmanTaskTypeIds) {
                return $query->whereIn('task_type_id', $craftsmanTaskTypeIds);
            })
            ->when(empty($craftsmanTaskTypeIds), function ($query) use ($user) {
                // If no task types selected, filter by category only
                return $query->whereHas('taskType', function ($q) use ($user) {
                    $q->where('category_id', $user->category_id);
                });
            })
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($order) => $this->transformOrder($order));

        // Combine assigned and available orders
        $allOrders = $assignedOrders->merge($availableOrders)->unique('id')->values();

        return response()->json([
            'success' => true,
            'data' => $allOrders,
            'message' => 'Assigned orders retrieved successfully',
        ]);
    }

    public function invite(Request $request, Order $order)
    {
        $user = $request->user();
        if (!$user || $user->id !== (int) $order->customer_id) {
            return response()->json([
                'success' => false,
                'message' => 'You are not authorized to invite craftsmen to this order',
            ], 403);
        }

        $validated = $request->validate([
            'craftsman_id' => 'required|exists:users,id',
        ]);

        if ($order->craftsman_status === 'waiting_response') {
            return response()->json([
                'success' => false,
                'message' => 'Craftsman already invited and awaiting response',
            ], 422);
        }

        $craftsman = User::where('id', $validated['craftsman_id'])
            ->where('user_type', 'craftsman')
            ->where('status', 'active')
            ->firstOrFail();

        $order->craftsman_id = $craftsman->id;
        $order->craftsman_status = 'waiting_response';
        $order->status = 'pending';
        $order->save();

        $chat = Chat::firstOrCreate(
            [
                'customer_id' => $order->customer_id,
                'craftsman_id' => $craftsman->id,
            ],
            [
                'order_id' => $order->id,
                'status' => 'active',
            ]
        );

        $chat->update([
            'order_id' => $order->id,
            'last_message' => 'New order invitation',
            'last_message_at' => now(),
            'customer_read' => true,
            'craftsman_read' => false,
        ]);

        return response()->json([
            'success' => true,
            'data' => $this->transformOrder($order),
            'message' => 'Craftsman invited successfully',
        ]);
    }

    public function accept(Request $request, Order $order)
    {
        $user = $request->user();
        if (!$user || $user->user_type !== 'craftsman' || $order->craftsman_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'You are not authorized to accept this order',
            ], 403);
        }

        if ($order->craftsman_status !== 'waiting_response') {
            return response()->json([
                'success' => false,
                'message' => 'Order is not awaiting your approval',
            ], 422);
        }

        $order->craftsman_status = 'accepted';
        $order->status = 'in_progress';
        $order->save();

        return response()->json([
            'success' => true,
            'data' => $this->transformOrder($order),
            'message' => 'Order accepted successfully',
        ]);
    }

    public function reject(Request $request, Order $order)
    {
        $user = $request->user();
        if (!$user || $user->user_type !== 'craftsman' || $order->craftsman_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'You are not authorized to reject this order',
            ], 403);
        }

        if ($order->craftsman_status !== 'waiting_response') {
            return response()->json([
                'success' => false,
                'message' => 'Order is not awaiting your approval',
            ], 422);
        }

        $order->craftsman_status = 'rejected';
        $order->craftsman_id = null;
        $order->status = 'pending';
        $order->save();

        return response()->json([
            'success' => true,
            'data' => $this->transformOrder($order),
            'message' => 'Order rejected successfully',
        ]);
    }

    protected function transformOrder(Order $order): array
    {
        // Check if order has a review
        $review = \App\Models\Review::where('order_id', $order->id)->first();
        
        return [
            'id' => $order->id,
            'customer_id' => $order->customer_id,
            'customer_name' => optional($order->customer)->name,
            'customer_phone' => optional($order->customer)->phone,
            'craftsman_id' => $order->craftsman_id,
            'craftsman_name' => optional($order->craftsman)->name,
            'task_type_id' => $order->task_type_id,
            'task_type_name' => optional($order->taskType)->name,
            'title' => $order->title,
            'description' => $order->description,
            'location' => $order->location,
            'governorate' => $order->governorate,
            'city' => $order->city,
            'district' => $order->district,
            'budget' => $order->budget,
            'preferred_date' => $order->preferred_date,
            'status' => $order->status,
            'craftsman_status' => $order->craftsman_status,
            'notes' => $order->notes,
            'images' => $order->images ?? [],
            'has_review' => $review ? true : false,
            'review' => $review ? [
                'id' => $review->id,
                'rating' => $review->rating,
                'comment' => $review->comment,
                'created_at' => optional($review->created_at)?->format('Y-m-d H:i:s'),
            ] : null,
            'created_at' => optional($order->created_at)?->format('Y-m-d H:i:s'),
        ];
    }
}
