<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\TaskType;

class TaskTypeController extends Controller
{
    public function index()
    {
        $taskTypes = TaskType::with('category')
            ->where('status', 'active')
            ->get()
            ->map(function ($taskType) {
                return [
                    'id' => $taskType->id,
                    'name' => $taskType->name,
                    'name_en' => $taskType->name_en,
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
                    'image' => 'https://via.placeholder.com/300x200/' . ltrim($taskType->color, '#') . '/000000?text=' . urlencode($taskType->name)
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $taskTypes,
            'message' => 'Task types retrieved successfully'
        ]);
    }
}
