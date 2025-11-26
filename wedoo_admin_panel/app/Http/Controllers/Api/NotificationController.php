<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function list(Request $request)
    {
        $user = $request->user();
        
        $notifications = $user->notifications()
            ->orderByDesc('created_at')
            ->paginate(20);
            
        return response()->json([
            'success' => true,
            'data' => $notifications,
            'message' => 'Notifications loaded successfully',
        ]);
    }

    public function send(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'title' => 'required|string',
            'message' => 'required|string',
            'type' => 'nullable|string',
            'data' => 'nullable|array',
        ]);

        $notification = \App\Models\Notification::create([
            'user_id' => $validated['user_id'],
            'title' => $validated['title'],
            'message' => $validated['message'],
            'type' => $validated['type'] ?? 'general',
            'data' => $validated['data'] ?? [],
            'is_read' => false,
        ]);

        return response()->json([
            'success' => true,
            'data' => $notification,
            'message' => 'Notification sent successfully',
        ]);
    }
}
