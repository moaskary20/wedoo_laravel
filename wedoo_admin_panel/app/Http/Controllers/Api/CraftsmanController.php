<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Chat;

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

    public function nearby(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'category_id' => 'nullable|exists:categories,id',
            'governorate' => 'nullable|string|max:255',
            'city' => 'nullable|string|max:255',
            'district' => 'nullable|string|max:255',
            'limit' => 'nullable|integer|min:1|max:20',
        ]);

        $limit = $validated['limit'] ?? 5;

        $query = User::with(['category'])
            ->withAvg('craftsmanReviews as rating_avg', 'rating')
            ->withCount('craftsmanReviews as rating_count')
            ->where('user_type', 'craftsman')
            ->where('status', 'active');

        if (!empty($validated['category_id'])) {
            $query->where('category_id', $validated['category_id']);
        }

        // Prioritize craftsmen in the same district/city/governorate
        if (!empty($validated['district'])) {
            $query->orderByRaw(
                'CASE 
                    WHEN district = ? THEN 0 
                    WHEN city = ? THEN 1 
                    WHEN governorate = ? THEN 2 
                    ELSE 3 
                END',
                [
                    $validated['district'],
                    $validated['city'] ?? $validated['district'],
                    $validated['governorate'] ?? $validated['city'] ?? $validated['district'],
                ]
            );
        } elseif (!empty($validated['city'])) {
            $query->orderByRaw(
                'CASE 
                    WHEN city = ? THEN 0 
                    WHEN governorate = ? THEN 1 
                    ELSE 2 
                END',
                [
                    $validated['city'],
                    $validated['governorate'] ?? $validated['city'],
                ]
            );
        } elseif (!empty($validated['governorate'])) {
            $query->orderByRaw(
                'CASE 
                    WHEN governorate = ? THEN 0 
                    ELSE 1 
                END',
                [$validated['governorate']]
            );
        } else {
            $query->orderByDesc('updated_at');
        }

        $craftsmen = $query->limit($limit)->get()->map(function (User $craftsman) use ($validated, $user) {
            $chatId = null;
            if ($user) {
                $chat = Chat::where('customer_id', $user->id)
                    ->where('craftsman_id', $craftsman->id)
                    ->first();
                $chatId = $chat?->id;
            }

            return [
                'id' => $craftsman->id,
                'chat_id' => $chatId,
                'name' => $craftsman->name,
                'phone' => $craftsman->phone,
                'category_id' => $craftsman->category_id,
                'category_name' => optional($craftsman->category)->name,
                'rating' => round($craftsman->rating_avg ?? 0, 1),
                'rating_count' => $craftsman->rating_count ?? 0,
                'governorate' => $craftsman->governorate,
                'city' => $craftsman->city,
                'district' => $craftsman->district,
                'distance_label' => $this->buildDistanceLabel($craftsman, $validated),
                'availability_status' => 'available',
                'craftsman_status' => 'awaiting_assignment',
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $craftsmen,
            'message' => 'Nearby craftsmen retrieved successfully',
        ]);
    }

    protected function buildDistanceLabel(User $craftsman, array $filters): string
    {
        if (!empty($filters['district']) && $filters['district'] === $craftsman->district) {
            return 'داخل نفس المنطقة';
        }

        if (!empty($filters['city']) && $filters['city'] === $craftsman->city) {
            return 'داخل نفس المدينة';
        }

        if (!empty($filters['governorate']) && $filters['governorate'] === $craftsman->governorate) {
            return 'في نفس المحافظة';
        }

        return 'متاح للتواصل';
    }
}
