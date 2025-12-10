<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Review;
use App\Models\Order;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    /**
     * Create a review for a completed order
     */
    public function create(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'order_id' => 'required|exists:orders,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        // Check if user is the customer of this order
        $order = Order::findOrFail($request->order_id);
        
        if ($order->customer_id != $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'You can only review orders that belong to you',
            ], 403);
        }

        // Check if order is completed
        if ($order->status !== 'completed' && $order->craftsman_status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'You can only review completed orders',
            ], 422);
        }

        // Check if review already exists for this order
        $existingReview = Review::where('order_id', $request->order_id)
            ->where('customer_id', $user->id)
            ->first();

        if ($existingReview) {
            // Update existing review
            $existingReview->update([
                'rating' => $request->rating,
                'comment' => $request->comment,
                'status' => 'approved', // Auto-approve updated reviews
            ]);

            return response()->json([
                'success' => true,
                'data' => $this->transformReview($existingReview),
                'message' => 'Review updated successfully',
            ]);
        }

        // Create new review
        $review = Review::create([
            'order_id' => $request->order_id,
            'customer_id' => $user->id,
            'craftsman_id' => $order->craftsman_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'status' => 'approved', // Auto-approve reviews
        ]);

        return response()->json([
            'success' => true,
            'data' => $this->transformReview($review),
            'message' => 'Review created successfully',
        ], 201);
    }

    /**
     * Get review for a specific order
     */
    public function getByOrder(Request $request, $orderId)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        $review = Review::where('order_id', $orderId)
            ->where('customer_id', $user->id)
            ->first();

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->transformReview($review),
        ]);
    }

    /**
     * Get all reviews for a craftsman
     */
    public function getByCraftsman(Request $request, $craftsmanId)
    {
        $reviews = Review::where('craftsman_id', $craftsmanId)
            ->where('status', 'approved')
            ->with(['customer', 'order'])
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($review) => $this->transformReview($review));

        $averageRating = Review::where('craftsman_id', $craftsmanId)
            ->where('status', 'approved')
            ->avg('rating');

        return response()->json([
            'success' => true,
            'data' => $reviews,
            'average_rating' => round($averageRating ?? 0, 1),
            'total_reviews' => $reviews->count(),
        ]);
    }

    /**
     * Check if order can be reviewed
     */
    public function canReview(Request $request, $orderId)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'can_review' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        $order = Order::find($orderId);
        if (!$order) {
            return response()->json([
                'success' => false,
                'can_review' => false,
                'message' => 'Order not found',
            ], 404);
        }

        // Check if user is the customer
        if ($order->customer_id != $user->id) {
            return response()->json([
                'success' => false,
                'can_review' => false,
                'message' => 'You can only review your own orders',
            ], 403);
        }

        // Check if order is completed
        $isCompleted = $order->status === 'completed' || $order->craftsman_status === 'completed';
        
        // Check if review already exists
        $hasReview = Review::where('order_id', $orderId)
            ->where('customer_id', $user->id)
            ->exists();

        return response()->json([
            'success' => true,
            'can_review' => $isCompleted && !$hasReview,
            'has_review' => $hasReview,
            'is_completed' => $isCompleted,
        ]);
    }

    /**
     * Transform review data for API response
     */
    protected function transformReview(Review $review): array
    {
        return [
            'id' => $review->id,
            'order_id' => $review->order_id,
            'customer_id' => $review->customer_id,
            'customer_name' => optional($review->customer)->name,
            'craftsman_id' => $review->craftsman_id,
            'craftsman_name' => optional($review->craftsman)->name,
            'rating' => $review->rating,
            'comment' => $review->comment,
            'status' => $review->status,
            'created_at' => optional($review->created_at)?->format('Y-m-d H:i:s'),
            'updated_at' => optional($review->updated_at)?->format('Y-m-d H:i:s'),
        ];
    }
}

