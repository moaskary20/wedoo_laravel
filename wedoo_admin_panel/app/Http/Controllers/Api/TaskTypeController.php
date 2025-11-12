<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TaskType;

class TaskTypeController extends Controller
{
    public function index(Request $request)
    {
        $query = TaskType::with('category')
            ->where('status', 'active');
        
        // Filter by category_id if provided
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }
        
        $taskTypes = $query->get()
            ->map(function ($taskType) {
                return [
                    'id' => $taskType->id,
                    'name' => $taskType->name, // Keep for backward compatibility
                    'name_ar' => $taskType->name_ar, // Arabic name
                    'name_fr' => $taskType->name_fr, // French name (formerly name_en)
                    'name_arabic' => $taskType->name_ar, // Alternative key for Arabic
                    'name_french' => $taskType->name_fr, // Alternative key for French
                    'category_id' => $taskType->category_id,
                    'category_name' => $taskType->category->name,
                    'description' => $taskType->description,
                    'icon' => $taskType->icon,
                    'color' => $taskType->color,
                    'price_range' => $taskType->price_range,
                    'duration' => $taskType->duration,
                    'difficulty' => $taskType->difficulty,
                    'status' => $taskType->status,
                    'created_at' => $taskType->created_at->format('Y-m-d'),
                    'image' => 'https://via.placeholder.com/300x200/' . ltrim($taskType->color, '#') . '/000000?text=' . urlencode($taskType->name_ar ?? $taskType->name)
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $taskTypes,
            'message' => 'Task types retrieved successfully'
        ]);
    }
}
