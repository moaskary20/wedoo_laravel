<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;

class CategoryController extends Controller
{
    public function list()
    {
        $categories = Category::where('status', 'active')
            ->get()
            ->map(function ($category) {
                return [
                    'id' => $category->id,
                    'name' => $category->name,
                    'name_en' => $category->name_en,
                    'description' => $category->description,
                    'icon' => $category->icon,
                    'image' => $category->image,
                    'status' => $category->status,
                    'created_at' => $category->created_at->format('Y-m-d')
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $categories,
            'message' => 'Categories retrieved successfully'
        ]);
    }
}
