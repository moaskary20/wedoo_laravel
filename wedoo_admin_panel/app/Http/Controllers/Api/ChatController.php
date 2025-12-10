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
        \Log::info('=== Chat messages endpoint called ===', [
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'query_params' => $request->query(),
            'has_auth' => $request->user() !== null,
            'user_id' => $request->user()?->id,
            'authorization_header' => $request->header('Authorization') ? 'present' : 'missing',
        ]);
        
        $user = $request->user();
        
        \Log::info('User from request', [
            'user_id' => $user?->id,
            'user_type' => $user?->user_type,
            'user_exists' => $user !== null,
        ]);
        
        // For support messages, allow unauthenticated requests with user_id
        if (!$user && $request->has('user_id')) {
            $userId = $request->input('user_id');
            $user = User::find($userId);
            \Log::info('Support message: Found user by user_id', [
                'user_id' => $userId,
                'user_found' => $user !== null,
            ]);
        }

        try {
            $validated = $request->validate([
                'chat_id' => 'nullable|exists:chats,id',
                'craftsman_id' => 'nullable|exists:users,id',
                'customer_id' => 'nullable|exists:users,id',
                'user_id' => 'nullable|exists:users,id', // For support messages
                'type' => 'nullable|string', // For support messages
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('Validation failed in chat messages', [
                'errors' => $e->errors(),
                'request_data' => $request->all(),
            ]);
            throw $e;
        }

        // Handle support messages request
        // Check for type=support first, even if chat_id is provided
        if ($request->has('type') && $request->input('type') === 'support') {
            \Log::info('Routing to getSupportMessages', [
                'user_id' => $user?->id,
                'request_user_id' => $request->input('user_id'),
                'chat_id' => $request->input('chat_id'),
            ]);
            return $this->getSupportMessages($request, $user);
        }

        // Check if we have required parameters
        // Logic: If user sends craftsman_id, they are acting as a customer
        //        If user sends customer_id, they are acting as a craftsman
        if (empty($validated['chat_id'])) {
            \Log::info('Checking user type and required parameters', [
                'user_id' => $user?->id,
                'user_type' => $user?->user_type,
                'user_name' => $user?->name,
                'has_customer_id' => !empty($validated['customer_id']),
                'has_craftsman_id' => !empty($validated['craftsman_id']),
                'craftsman_id_value' => $validated['craftsman_id'] ?? null,
                'customer_id_value' => $validated['customer_id'] ?? null,
                'validated' => $validated,
            ]);
            
            // Determine user's role based on what they're sending, not just user_type
            // If they send craftsman_id, they want to chat as a customer
            // If they send customer_id, they want to chat as a craftsman
            $hasCraftsmanId = !empty($validated['craftsman_id']);
            $hasCustomerId = !empty($validated['customer_id']);
            
            if ($hasCraftsmanId && !$hasCustomerId) {
                // User is acting as customer (sending craftsman_id to chat with craftsman)
                // This is valid - no need to check user_type
                \Log::info('User acting as customer (sending craftsman_id)', [
                    'user_id' => $user?->id,
                    'user_type' => $user?->user_type,
                    'craftsman_id' => $validated['craftsman_id'],
                ]);
            } else if ($hasCustomerId && !$hasCraftsmanId) {
                // User is acting as craftsman (sending customer_id to chat with customer)
                // This is valid - no need to check user_type
                \Log::info('User acting as craftsman (sending customer_id)', [
                    'user_id' => $user?->id,
                    'user_type' => $user?->user_type,
                    'customer_id' => $validated['customer_id'],
                ]);
            } else if (!$hasCraftsmanId && !$hasCustomerId) {
                // Neither provided - check based on user_type as fallback
                if ($user && $user->user_type === 'craftsman') {
                    throw ValidationException::withMessages([
                        'customer_id' => 'customer_id is required when craftsman requests messages',
                    ]);
                } else if ($user) {
                    throw ValidationException::withMessages([
                        'craftsman_id' => 'craftsman_id is required when customer requests messages',
                    ]);
                } else {
                    throw ValidationException::withMessages([
                        'chat_id' => 'chat_id or (customer_id and craftsman_id) is required',
                    ]);
                }
            }
        }

        if (!empty($validated['craftsman_id'])) {
            // Only try to find craftsman if user is not a craftsman (i.e., customer requesting messages)
            // If user is craftsman, they should provide customer_id instead
            if ($user && $user->user_type !== 'craftsman') {
                $craftsman = User::where('id', $validated['craftsman_id'])
                    ->where('user_type', 'craftsman')
                    ->first();
                if (!$craftsman) {
                    throw ValidationException::withMessages([
                        'craftsman_id' => 'Craftsman not found',
                    ]);
                }
            }
        }

        if (!empty($validated['chat_id'])) {
            $chat = Chat::findOrFail($validated['chat_id']);
            // Load relationships safely (won't fail if user doesn't exist)
            $chat->loadMissing(['customer', 'craftsman', 'order']);
        } else {
            // Determine customer_id based on request parameters, not just user_type
            // If user sends craftsman_id, they are acting as customer
            // If user sends customer_id, they are acting as craftsman
            $customerId = null;
            $hasCraftsmanId = !empty($validated['craftsman_id']);
            $hasCustomerId = !empty($validated['customer_id']);
            
            if ($user) {
                if ($hasCraftsmanId && !$hasCustomerId) {
                    // User is sending craftsman_id - they are acting as customer
                    // Use authenticated user's ID as customer_id
                    $customerId = $user->id;
                    \Log::info('User acting as customer (sent craftsman_id)', [
                        'user_id' => $user->id,
                        'user_type' => $user->user_type,
                        'user_name' => $user->name,
                        'customer_id' => $customerId,
                        'craftsman_id' => $validated['craftsman_id'],
                        'has_craftsman_id' => $hasCraftsmanId,
                        'has_customer_id' => $hasCustomerId,
                    ]);
                } else if ($hasCustomerId && !$hasCraftsmanId) {
                    // User is sending customer_id - they are acting as craftsman
                    // Use customer_id from request
                    $customerId = $validated['customer_id'];
                    \Log::info('User acting as craftsman (sent customer_id)', [
                        'user_id' => $user->id,
                        'user_type' => $user->user_type,
                        'customer_id' => $customerId,
                    ]);
                } else {
                    // Fallback to user_type if parameters are ambiguous
                    if ($user->user_type === 'craftsman') {
                        $customerId = $validated['customer_id'] ?? null;
                    } else {
                        $customerId = $user->id;
                    }
                }
                } else if ($hasCustomerId && !$hasCraftsmanId) {
                    // User is sending customer_id - they are acting as craftsman
                    // Use customer_id from request
                    $customerId = $validated['customer_id'];
                    \Log::info('User acting as craftsman (sent customer_id)', [
                        'user_id' => $user->id,
                        'user_type' => $user->user_type,
                        'customer_id' => $customerId,
                    ]);
                } else {
                    // Fallback to user_type if parameters are ambiguous
                    if ($user->user_type === 'craftsman') {
                        $customerId = $validated['customer_id'] ?? null;
                    } else {
                        $customerId = $user->id;
                    }
                }
            } else {
                // No authenticated user
                if ($hasCraftsmanId && !$hasCustomerId) {
                    // User is sending craftsman_id but not authenticated
                    // This means they want to chat as a customer, but we need customer_id
                    // Since they're not authenticated, we can't determine customer_id
                    \Log::warning('Unauthenticated user sending craftsman_id without customer_id', [
                        'craftsman_id' => $validated['craftsman_id'],
                    ]);
                    throw ValidationException::withMessages([
                        'customer_id' => 'Authentication required. Please log in to chat with a craftsman.',
                    ]);
                } else {
                    // Get customer_id from request
                    $customerId = $validated['customer_id'] ?? null;
                }
            }

            \Log::info('Determined customer_id', [
                'user_id' => $user?->id,
                'user_type' => $user?->user_type,
                'user_authenticated' => $user !== null,
                'customer_id' => $customerId,
                'has_craftsman_id' => $hasCraftsmanId,
                'has_customer_id' => $hasCustomerId,
                'validated_customer_id' => $validated['customer_id'] ?? null,
            ]);

            if (!$customerId) {
                $errorMessage = $user 
                    ? 'Unable to determine customer_id. Please provide customer_id or ensure you are authenticated as a customer.'
                    : 'Authentication required. Please log in to use the chat feature.';
                throw ValidationException::withMessages([
                    'customer_id' => $errorMessage,
                ]);
            }

            // Verify customer exists
            $customer = User::find($customerId);
            if (!$customer) {
                throw ValidationException::withMessages([
                    'customer_id' => 'Customer not found',
                ]);
            }

            if ($user && $user->user_type !== 'craftsman') {
                // Verify craftsman exists
                if (!empty($validated['craftsman_id'])) {
                    $craftsman = User::find($validated['craftsman_id']);
                    if (!$craftsman || $craftsman->user_type !== 'craftsman') {
                        throw ValidationException::withMessages([
                            'craftsman_id' => 'Craftsman not found',
                        ]);
                    }
                }

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
                // For craftsman, use their ID as craftsman_id
                // If user is craftsman, use their ID; otherwise use craftsman_id from request
                \Log::info('Creating chat for craftsman', [
                    'user_id' => $user?->id,
                    'user_type' => $user?->user_type,
                    'customer_id' => $customerId,
                    'craftsman_id_from_request' => $validated['craftsman_id'] ?? null,
                ]);
                
                if ($user && $user->user_type === 'craftsman') {
                    $craftsmanId = $user->id;
                    \Log::info('Using craftsman user ID', ['craftsman_id' => $craftsmanId]);
                } else {
                    // If no user or user is not craftsman, try to get craftsman_id from request
                    $craftsmanId = $validated['craftsman_id'] ?? null;
                    
                    // If user is null but we have customer_id, this might mean the user is not authenticated
                    // In this case, we need craftsman_id from the request
                    if (!$craftsmanId) {
                        \Log::warning('craftsman_id is missing', [
                            'user' => $user ? 'exists' : 'null',
                            'user_type' => $user?->user_type,
                            'customer_id' => $customerId,
                            'validated' => $validated,
                        ]);
                        
                        // If user is null, they need to authenticate or provide craftsman_id
                        if (!$user) {
                            throw ValidationException::withMessages([
                                'craftsman_id' => 'craftsman_id is required when user is not authenticated. Please authenticate or provide craftsman_id.',
                            ]);
                        } else {
                            throw ValidationException::withMessages([
                                'craftsman_id' => 'craftsman_id is required when user is not a craftsman',
                            ]);
                        }
                    }
                }
                
                $chat = Chat::firstOrCreate(
                    [
                        'customer_id' => $customerId,
                        'craftsman_id' => $craftsmanId,
                    ],
                    [
                        'status' => 'active',
                    ]
                );
                
                \Log::info('Chat created/found', [
                    'chat_id' => $chat->id,
                    'customer_id' => $chat->customer_id,
                    'craftsman_id' => $chat->craftsman_id,
                ]);
            }

            // Load relationships safely
            $chat->loadMissing(['customer', 'craftsman', 'order']);
        }

        // Only authorize if user is not admin (admin can access all chats)
        if ($user && $user->user_type !== 'admin') {
            $this->authorizeChat($chat, $user);
        }

        $messages = $chat->messages()->orderBy('created_at')->get();

        if ($user) {
            $chat->messages()
                ->where('sender_id', '!=', $user->id)
                ->where('is_read', false)
                ->update(['is_read' => true, 'read_at' => now()]);

            if ($user->user_type === 'craftsman') {
                $chat->update(['craftsman_read' => true]);
            } else {
                $chat->update(['customer_read' => true]);
            }
        }

        // Refresh chat with relationships safely
        $chat->refresh();
        $chat->loadMissing(['customer', 'craftsman', 'order']);

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat, $user),
                'messages' => $messages->map(fn (ChatMessage $message) => $this->transformMessage($message, $user)),
            ],
            'message' => 'Chat messages loaded successfully',
        ]);
    }
    
    protected function getSupportMessages(Request $request, ?User $user)
    {
        \Log::info('=== getSupportMessages called ===', [
            'user_id' => $user?->id,
            'request_user_id' => $request->input('user_id'),
            'chat_id' => $request->input('chat_id'),
            'type' => $request->input('type'),
        ]);
        
        $userId = $user?->id ?? $request->input('user_id');
        $chatId = $request->input('chat_id');
        
        \Log::info('getSupportMessages: Resolved IDs', [
            'resolved_user_id' => $userId,
            'resolved_chat_id' => $chatId,
        ]);
        
        // If chat_id is provided, use it directly
        if ($chatId) {
            $chat = Chat::with(['customer', 'craftsman'])->find($chatId);
            
            if (!$chat) {
                return response()->json([
                    'success' => false,
                    'message' => 'Chat not found',
                ], 404);
            }
            
            // Verify this is a support chat (craftsman is admin)
            // Check if craftsman is an admin (not just the first admin)
            $craftsman = $chat->craftsman;
            if (!$craftsman || $craftsman->user_type !== 'admin') {
                \Log::warning('Support messages: Chat is not a support chat', [
                    'chat_id' => $chatId,
                    'craftsman_id' => $chat->craftsman_id,
                    'craftsman_type' => $craftsman?->user_type,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'This is not a support chat',
                ], 403);
            }
            
            $messages = $chat->messages()->orderBy('created_at')->get();
            
            \Log::info('Loading support messages by chat_id', [
                'chat_id' => $chatId,
                'messages_count' => $messages->count(),
                'user_id' => $userId,
                'messages' => $messages->map(function ($msg) {
                    return [
                        'id' => $msg->id,
                        'sender_id' => $msg->sender_id,
                        'message' => substr($msg->message, 0, 50),
                        'created_at' => $msg->created_at,
                    ];
                })->toArray(),
            ]);
            
            // Mark messages as read for customer
            if ($user) {
                $chat->messages()
                    ->where('sender_id', '!=', $user->id)
                    ->where('is_read', false)
                    ->update(['is_read' => true, 'read_at' => now()]);
                $chat->update(['customer_read' => true]);
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'chat' => $this->transformChat($chat, $user),
                    'messages' => $messages->map(fn (ChatMessage $message) => $this->transformMessage($message, $user)),
                ],
                'message' => 'Support messages loaded successfully',
            ]);
        }
        
        // If no chat_id, find by user_id
        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'User ID or Chat ID is required for support messages',
            ], 400);
        }

        // Get admin user for support
        $adminUser = User::where('user_type', 'admin')->first();
        if (!$adminUser) {
            $adminUser = User::firstOrCreate(
                ['email' => 'support@wedoo.com'],
                [
                    'name' => 'Support Team',
                    'user_type' => 'admin',
                    'status' => 'active',
                    'password' => bcrypt('support123'),
                ]
            );
        }

        // Find support chat for this user
        $chat = Chat::where('customer_id', $userId)
            ->where('craftsman_id', $adminUser->id)
            ->first();

        if (!$chat) {
            // Return empty messages if chat doesn't exist yet
            return response()->json([
                'success' => true,
                'data' => [
                    'chat' => null,
                    'messages' => [],
                ],
                'message' => 'No support chat found',
            ]);
        }

        $chat->load(['customer', 'craftsman']);
        $messages = $chat->messages()->orderBy('created_at')->get();

        \Log::info('Loading support messages', [
            'chat_id' => $chat->id,
            'user_id' => $userId,
            'messages_count' => $messages->count(),
        ]);

        // Mark messages as read for customer
        if ($user) {
            $chat->messages()
                ->where('sender_id', '!=', $user->id)
                ->where('is_read', false)
                ->update(['is_read' => true, 'read_at' => now()]);
            $chat->update(['customer_read' => true]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat, $user),
                'messages' => $messages->map(fn (ChatMessage $message) => $this->transformMessage($message, $user)),
            ],
            'message' => 'Support messages loaded successfully',
        ]);
    }

    public function send(Request $request)
    {
        // Log incoming request
        \Log::info('Chat send request received', [
            'type' => $request->input('type'),
            'user_id' => $request->user()?->id,
            'message' => substr($request->input('message', ''), 0, 100),
            'all_data' => $request->all(),
        ]);

        if ($request->input('type') === 'support') {
            return $this->handleSupportMessage($request);
        }

        $user = $request->user();
        
        // Allow admin to reply to support chats
        if ($user && $user->user_type === 'admin') {
            return $this->handleAdminReply($request, $user);
        }

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
                ->first();
            if (!$craftsman) {
                throw ValidationException::withMessages([
                    'craftsman_id' => 'Craftsman not found',
                ]);
            }
        }

        if (!empty($validated['chat_id'])) {
            $chat = Chat::findOrFail($validated['chat_id']);
            $chat->loadMissing(['customer', 'craftsman', 'order']);
        } else {
            $customerId = ($user && $user->user_type === 'craftsman')
                ? ($validated['customer_id'] ?? null)
                : ($user ? $user->id : ($validated['customer_id'] ?? null));

            if (!$customerId) {
                throw ValidationException::withMessages([
                    'customer_id' => 'customer_id is required when craftsman sends a new message',
                ]);
            }

            // Verify customer exists
            $customer = User::find($customerId);
            if (!$customer) {
                throw ValidationException::withMessages([
                    'customer_id' => 'Customer not found',
                ]);
            }

            $craftsmanId = ($user && $user->user_type === 'craftsman')
                ? $user->id
                : ($validated['craftsman_id'] ?? null);

            if (!$craftsmanId) {
                throw ValidationException::withMessages([
                    'craftsman_id' => 'craftsman_id is required',
                ]);
            }

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
            
            // Load relationships safely
            $chat->loadMissing(['customer', 'craftsman', 'order']);
        }

        $this->authorizeChat($chat, $user);

        if (!empty($validated['order_id']) && !$chat->order_id) {
            $chat->order_id = $validated['order_id'];
        }

        $chat->loadMissing('order');

        // Allow chat before order acceptance - customers and craftsmen can chat before accepting
        // This enables communication during the invitation phase

        if (!$user) {
            throw ValidationException::withMessages([
                'user' => 'User must be authenticated to send messages',
            ]);
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

            // Refresh chat with relationships safely
            $chat->refresh();
            $chat->loadMissing(['customer', 'craftsman', 'order']);

            return response()->json([
                'success' => true,
                'data' => [
                    'chat' => $this->transformChat($chat, $user),
                    'message' => $this->transformMessage($message, $user),
                ],
                'message' => 'Message sent successfully',
            ]);
    }

    protected function authorizeChat(Chat $chat, User $user): void
    {
        // Admin can access all chats
        if ($user->user_type === 'admin') {
            return;
        }

        if ($user->user_type === 'craftsman' && $chat->craftsman_id !== $user->id) {
            abort(403, 'Unauthorized chat access');
        }

        if ($user->user_type !== 'craftsman' && $chat->customer_id !== $user->id) {
            abort(403, 'Unauthorized chat access');
        }
    }

    protected function transformChat(Chat $chat, ?User $user = null): array
    {
        // Safely get customer and craftsman without triggering errors
        $customer = null;
        $craftsman = null;
        
        try {
            $customer = $chat->customer;
        } catch (\Exception $e) {
            \Log::warning('Customer not found for chat', [
                'chat_id' => $chat->id,
                'customer_id' => $chat->customer_id,
                'error' => $e->getMessage(),
            ]);
        }
        
        try {
            $craftsman = $chat->craftsman;
        } catch (\Exception $e) {
            \Log::warning('Craftsman not found for chat', [
                'chat_id' => $chat->id,
                'craftsman_id' => $chat->craftsman_id,
                'error' => $e->getMessage(),
            ]);
        }
        
        $otherParty = null;
        if ($user) {
            $otherParty = $user->user_type === 'craftsman'
                ? $customer
                : $craftsman;
        } else {
            // If no user, determine other party based on chat context
            // For support chats, the other party is the admin (craftsman)
            if ($craftsman && $craftsman->user_type === 'admin') {
                $otherParty = $craftsman;
            } else {
                $otherParty = $craftsman ?? $customer;
            }
        }

        $unreadCount = 0;
        if ($user) {
            $unreadCount = $chat->messages()
                ->where('sender_id', '!=', $user->id)
                ->where('is_read', false)
                ->count();
        } else {
            // If no user, count all unread messages
            $unreadCount = $chat->messages()
                ->where('is_read', false)
                ->count();
        }

        return [
            'id' => $chat->id,
            'order_id' => $chat->order_id,
            'status' => $chat->status,
            'last_message' => $chat->last_message,
            'last_message_at' => optional($chat->last_message_at)->toIso8601String(),
            'unread_count' => $unreadCount,
            'customer' => $customer ? [
                'id' => $customer->id,
                'name' => $customer->name,
                'phone' => $customer->phone,
            ] : null,
            'craftsman' => $craftsman ? [
                'id' => $craftsman->id,
                'name' => $craftsman->name,
                'phone' => $craftsman->phone,
                'category_id' => $craftsman->category_id,
            ] : null,
            'order' => $chat->order ? [
                'id' => $chat->order->id,
                'title' => $chat->order->title,
                'status' => $chat->order->status,
            ] : null,
        ];
    }

    protected function transformMessage(ChatMessage $message, ?User $user = null): array
    {
        // Safely get sender without triggering errors
        $sender = null;
        $senderType = 'user';
        $senderName = 'مستخدم';
        
        try {
            $sender = $message->sender;
            if ($sender) {
                $senderType = $sender->user_type ?? 'user';
                $senderName = $sender->name ?? 'مستخدم';
            }
        } catch (\Exception $e) {
            \Log::warning('Sender not found for message', [
                'message_id' => $message->id,
                'sender_id' => $message->sender_id,
                'error' => $e->getMessage(),
            ]);
        }
        
        return [
            'id' => $message->id,
            'chat_id' => $message->chat_id,
            'text' => $message->message,
            'message' => $message->message, // Also include as 'message' for compatibility
            'message_type' => $message->message_type,
            'is_me' => $user ? ($message->sender_id === $user->id) : false,
            'sender_id' => $message->sender_id,
            'sender_type' => $senderType,
            'sender_name' => $senderName, // Add sender name
            'created_at' => $message->created_at?->toIso8601String(),
            'is_read' => $message->is_read,
        ];
    }

    protected function handleSupportMessage(Request $request)
    {
        // Get user from request (can be from auth or user_id parameter)
        $user = $request->user();
        $userId = $user?->id ?? $request->input('user_id');
        
        if (!$userId) {
            \Log::error('Support message: No user ID provided', [
                'request_data' => $request->all(),
                'has_auth_user' => $user !== null,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'User ID is required. Please provide user_id in request body or authenticate.',
            ], 400);
        }

        $validated = $request->validate([
            'message' => 'required|string|max:5000',
            'conversation_id' => 'nullable|string',
            'user_id' => 'nullable|exists:users,id',
        ]);

        // Get the user object
        if (!$user) {
            $user = User::find($userId);
            if (!$user) {
                \Log::error('Support message: User not found', ['user_id' => $userId]);
                return response()->json([
                    'success' => false,
                    'message' => 'User not found',
                ], 404);
            }
        }

        \Log::info('Support message validated', [
            'user_id' => $userId,
            'user_name' => $user->name,
            'message_length' => strlen($validated['message']),
            'conversation_id' => $validated['conversation_id'] ?? null,
        ]);

        // Get admin user for support (first admin user or create one)
        $adminUser = User::where('user_type', 'admin')->first();
        if (!$adminUser) {
            // If no admin exists, use user ID 1 or create a support user
            $adminUser = User::firstOrCreate(
                ['email' => 'support@wedoo.com'],
                [
                    'name' => 'Support Team',
                    'user_type' => 'admin',
                    'status' => 'active',
                    'password' => bcrypt('support123'), // Default password, should be changed
                ]
            );
            \Log::info('Support admin user created', ['admin_user_id' => $adminUser->id]);
        }

        // Find or create support chat
        // Use firstOrCreate to avoid unique constraint violation
        $chat = Chat::where('customer_id', $userId)
            ->where('craftsman_id', $adminUser->id)
            ->first();

        if (!$chat) {
            $chat = Chat::create([
                'customer_id' => $userId,
                'craftsman_id' => $adminUser->id,
                'status' => 'active',
            ]);
            \Log::info('Support chat created', ['chat_id' => $chat->id]);
        }

        // Create the message
        $message = $chat->messages()->create([
            'sender_id' => $userId,
            'message' => $validated['message'],
            'message_type' => 'text',
        ]);

        // Update chat
        $chat->last_message = $validated['message'];
        $chat->last_message_at = now();
        $chat->customer_read = true;
        $chat->craftsman_read = false;
        $chat->save();

        \Log::info('Support message saved successfully', [
            'chat_id' => $chat->id,
            'message_id' => $message->id,
            'user_id' => $userId,
            'message_preview' => substr($validated['message'], 0, 50),
        ]);

        // Reload chat with relationships
        $chat->load(['customer', 'craftsman']);

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat, $user),
                'message' => $this->transformMessage($message, $user),
            ],
            'message' => 'Support message sent successfully',
        ], 201);
    }

    protected function handleAdminReply(Request $request, User $adminUser)
    {
        \Log::info('Admin reply request received', [
            'admin_id' => $adminUser->id,
            'request_data' => $request->all(),
        ]);

        $validated = $request->validate([
            'chat_id' => 'required|exists:chats,id',
            'message' => 'required|string|max:5000',
            'message_type' => 'nullable|string|in:text,image,file',
        ]);

        $chat = Chat::findOrFail($validated['chat_id']);
        $chat->loadMissing(['customer', 'craftsman']);

        // Verify admin has access to this chat (support chats have admin as craftsman)
        if ($chat->craftsman_id !== $adminUser->id && $adminUser->user_type !== 'admin') {
            \Log::error('Admin reply: Unauthorized access', [
                'admin_id' => $adminUser->id,
                'chat_id' => $chat->id,
                'chat_craftsman_id' => $chat->craftsman_id,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access to this chat',
            ], 403);
        }

        // Create the reply message
        $message = $chat->messages()->create([
            'sender_id' => $adminUser->id,
            'message' => $validated['message'],
            'message_type' => $validated['message_type'] ?? 'text',
        ]);

        // Update chat
        $chat->last_message = $validated['message'];
        $chat->last_message_at = now();
        $chat->craftsman_read = true;
        $chat->customer_read = false;
        $chat->save();

        \Log::info('Admin reply saved successfully', [
            'chat_id' => $chat->id,
            'message_id' => $message->id,
            'admin_id' => $adminUser->id,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'chat' => $this->transformChat($chat->refresh()->loadMissing(['customer', 'craftsman']), $adminUser),
                'message' => $this->transformMessage($message, $adminUser),
            ],
            'message' => 'Reply sent successfully',
        ], 201);
    }
}
