<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TaskTypeController extends Controller
{
    public function index(Request $request)
    {
        $category_id = $request->get('category_id', 1);

        try {
            $task_types = DB::table('task_types')
                ->leftJoin('categories', 'task_types.category_id', '=', 'categories.id')
                ->where('task_types.category_id', $category_id)
                ->where('task_types.status', 'active')
                ->orderBy('task_types.created_at', 'asc')
                ->select(
                    'task_types.id',
                    'task_types.name',
                    'task_types.name_en',
                    'task_types.category_id',
                    'categories.name as category_name',
                    'task_types.description',
                    'task_types.icon',
                    'task_types.color',
                    'task_types.price_range',
                    'task_types.duration',
                    'task_types.difficulty',
                    'task_types.status',
                    'task_types.created_at'
                )
                ->get();

            // Format the response
            $formatted_task_types = $task_types->map(function ($task) {
                return [
                    'id' => $task->id,
                    'name' => $task->name,
                    'name_en' => $task->name_en,
                    'category_id' => $task->category_id,
                    'category_name' => $task->category_name,
                    'description' => $task->description,
                    'icon' => $task->icon,
                    'color' => $task->color,
                    'price_range' => $task->price_range,
                    'duration' => $task->duration,
                    'difficulty' => $task->difficulty,
                    'status' => $task->status,
                    'created_at' => $task->created_at,
                    'image' => 'https://via.placeholder.com/300x200/' . ltrim($task->color, '#') . '/000000?text=' . urlencode($task->name)
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $formatted_task_types,
                'message' => 'Task types retrieved successfully'
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
