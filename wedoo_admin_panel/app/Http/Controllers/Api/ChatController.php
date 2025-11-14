<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ChatController extends Controller
{
    public function list(Request $request)
    {
        $user = $request->user();

        $chats = Chat::with(['customer:id,name,phone,governorate,city,district', 'craftsman:id,name,phone,governorate,city,district,category_id', 'order:id,title,status'])
            ->when($user->user_type === 'craftsman', function ($query) use ($user) {
                $query->where('craftsman_id', $user->id);
            }, function ($query) use ($user) {
                $query->where('customer_id', $user->id);
            })
            ->orderByDesc('updated_at')
            ->get();

        $data = $chats->map(function (Chat $chat) use ($user) {
            return $this->transformChat($chat, $user);
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'message' => 'Chat conversations loaded successfully',
        ]);
    }

    public function messages(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'chat_id' => 'nullable|exists:chats,id',
            'craftsman_id' => 'nullable|exists:users,id',
            'customer_id' => 'nullable|exists:users,id',
        ]);

        if (empty($validated['chat_id']) && empty($validated['craftsman_id'])) {
            throw ValidationException::withMessages([
                'chat_id' => 'chat_id or craftsman_id is required',
            ]);
        }

        if (!empty($validated['craftsman_id'])) {
            $craftsman = User::where('id', $validated['craftsman_id'])
                ->where('user_type', 'craftsman')
                ->firstOrFail();
        }

        if (!empty($validated['chat_id'])) {
            $chat = Chat::with(['customer', 'craftsman', 'order'])
                ->findOrFail($validated['chat_id']);
        } else {
            $customerId = $user->user_type === 'craftsman'
                ? ($validated['customer_id'] ?? null)
                : $user->id;

            if (!$customerId) {
                throw ValidationException::withMessages([
                    'customer_id' => 'customer_id is required when craftsman requests messages',
                ]);
            }

            if ($user->user_type !== 'craftsman') {
                $chat = Chat::firstOrCreate(
                    [
                        'customer_id' => $customerId,
                        'craftsman_id' => $validated['craftsman_id'],
                    ],
                    [
                        'status' => 'active',
                    ]
                );
            } else {
                $chat = Chat::firstOrCreate(
                    [
                        'customer_id' => $customerId,
                        'craftsman_id' => $user->id,
                    ],
                    [
                        'status' => 'active',
                    ]
                );
            }

            $chat->load(['customer', 'craftsman', 'order']);
        }

        $this->authorizeChat($chat, $user);

        $messages = $chat->messages()->orderBy('created_at')->get();

        $chat->messages()
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true, 'read_at' => now()]);

        if ($user->user_type === 'craftsman') {
            $chat->update(['craftsman_read' => true]);
        } else {
            $chat->update(['customer_read' => true]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat->fresh(['customer', 'craftsman', 'order']), $user),
                'messages' => $messages->map(fn (ChatMessage $message) => $this->transformMessage($message, $user)),
            ],
            'message' => 'Chat messages loaded successfully',
        ]);
    }

    public function send(Request $request)
    {
        if ($request->input('type') === 'support') {
            // Placeholder for support chat integration
            return response()->json([
                'success' => true,
                'data' => [
                    'message' => 'Support message received',
                ],
                'message' => 'Support chat is not implemented yet',
            ]);
        }

        $user = $request->user();

        $validated = $request->validate([
            'chat_id' => 'nullable|exists:chats,id',
            'craftsman_id' => 'nullable|exists:users,id',
            'customer_id' => 'nullable|exists:users,id',
            'order_id' => 'nullable|exists:orders,id',
            'message' => 'required|string',
            'message_type' => 'nullable|string|in:text,image,file',
        ]);

        if (empty($validated['chat_id']) && empty($validated['craftsman_id'])) {
            throw ValidationException::withMessages([
                'craftsman_id' => 'craftsman_id is required when chat_id is not provided',
            ]);
        }

        if (!empty($validated['craftsman_id'])) {
            $craftsman = User::where('id', $validated['craftsman_id'])
                ->where('user_type', 'craftsman')
                ->firstOrFail();
        }

        if (!empty($validated['chat_id'])) {
            $chat = Chat::findOrFail($validated['chat_id']);
        } else {
            $customerId = $user->user_type === 'craftsman'
                ? ($validated['customer_id'] ?? null)
                : $user->id;

            if (!$customerId) {
                throw ValidationException::withMessages([
                    'customer_id' => 'customer_id is required when craftsman sends a new message',
                ]);
            }

            $craftsmanId = $user->user_type === 'craftsman'
                ? $user->id
                : $validated['craftsman_id'];

            $chat = Chat::firstOrCreate(
                [
                    'customer_id' => $customerId,
                    'craftsman_id' => $craftsmanId,
                ],
                [
                    'order_id' => $validated['order_id'] ?? null,
                    'status' => 'active',
                ]
            );
        }

        $this->authorizeChat($chat, $user);

        if (!empty($validated['order_id']) && !$chat->order_id) {
            $chat->order_id = $validated['order_id'];
        }

        $chat->load('order');

        if ($chat->order && $chat->order->craftsman_status !== 'accepted') {
            return response()->json([
                'success' => false,
                'message' => 'Craftsman must accept the order before starting the chat',
            ], 422);
        }

        $message = $chat->messages()->create([
            'sender_id' => $user->id,
            'message' => $validated['message'],
            'message_type' => $validated['message_type'] ?? 'text',
        ]);

        $chat->last_message = $validated['message'];
        $chat->last_message_at = now();

        if ($user->user_type === 'craftsman') {
            $chat->craftsman_read = true;
            $chat->customer_read = false;
        } else {
            $chat->customer_read = true;
            $chat->craftsman_read = false;
        }

        $chat->save();

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat->fresh(['customer', 'craftsman', 'order']), $user),
                'message' => $this->transformMessage($message, $user),
            ],
            'message' => 'Message sent successfully',
        ]);
    }

    protected function authorizeChat(Chat $chat, User $user): void
    {
        if ($user->user_type === 'craftsman' && $chat->craftsman_id !== $user->id) {
            abort(403, 'Unauthorized chat access');
        }

        if ($user->user_type !== 'craftsman' && $chat->customer_id !== $user->id) {
            abort(403, 'Unauthorized chat access');
        }
    }

    protected function transformChat(Chat $chat, User $user): array
    {
        $otherParty = $user->user_type === 'craftsman'
            ? $chat->customer
            : $chat->craftsman;

        $unreadCount = $chat->messages()
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->count();

        return [
            'id' => $chat->id,
            'order_id' => $chat->order_id,
            'status' => $chat->status,
            'last_message' => $chat->last_message,
            'last_message_at' => optional($chat->last_message_at)->toIso8601String(),
            'unread_count' => $unreadCount,
            'customer' => $chat->customer ? [
                'id' => $chat->customer->id,
                'name' => $chat->customer->name,
                'phone' => $chat->customer->phone,
            ] : null,
            'craftsman' => $chat->craftsman ? [
                'id' => $chat->craftsman->id,
                'name' => $chat->craftsman->name,
                'phone' => $chat->craftsman->phone,
                'category_id' => $chat->craftsman->category_id,
            ] : null,
            'order' => $chat->order ? [
                'id' => $chat->order->id,
                'title' => $chat->order->title,
                'status' => $chat->order->status,
            ] : null,
        ];
    }

    protected function transformMessage(ChatMessage $message, User $user): array
    {
        return [
            'id' => $message->id,
            'chat_id' => $message->chat_id,
            'text' => $message->message,
            'message_type' => $message->message_type,
            'is_me' => $message->sender_id === $user->id,
            'sender_id' => $message->sender_id,
            'created_at' => $message->created_at?->toIso8601String(),
            'is_read' => $message->is_read,
        ];
    }
}
