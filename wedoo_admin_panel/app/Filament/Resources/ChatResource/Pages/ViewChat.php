<?php

namespace App\Filament\Resources\ChatResource\Pages;

use App\Filament\Resources\ChatResource;
use App\Models\ChatMessage;
use App\Models\User;
use Filament\Actions;
use Filament\Forms;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewChat extends ViewRecord
{
    protected static string $resource = ChatResource::class;

    public ?string $replyMessage = '';

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\Action::make('reply')
                ->label('رد على المحادثة')
                ->icon('heroicon-o-chat-bubble-left-right')
                ->form([
                    Textarea::make('message')
                        ->label('الرسالة')
                        ->required()
                        ->maxLength(5000)
                        ->rows(5)
                        ->placeholder('اكتب ردك هنا...'),
                ])
                ->action(function (array $data) {
                    $chat = $this->record;
                    $adminUser = Auth::user();
                    
                    if (!$adminUser) {
                        Notification::make()
                            ->title('خطأ')
                            ->body('يجب تسجيل الدخول أولاً')
                            ->danger()
                            ->send();
                        return;
                    }

                    // Determine sender ID
                    // For support chats, always use the admin's ID as sender
                    // The craftsman_id in support chats is the admin who created the chat
                    // But any admin can reply, so we use the current admin's ID
                    $senderId = $adminUser->id;
                    
                    // For support chats, if the craftsman is an admin, we can use the current admin's ID
                    // This allows any admin to reply to support chats
                    $isSupportChat = $chat->craftsman && $chat->craftsman->user_type === 'admin';
                    
                    if ($isSupportChat) {
                        // For support chats, use the current admin's ID
                        $senderId = $adminUser->id;
                    } else if ($chat->craftsman_id === $adminUser->id) {
                        // If admin is the craftsman in a regular chat, use admin's ID
                        $senderId = $adminUser->id;
                    } else {
                        // Fallback: use craftsman_id (shouldn't happen for support chats)
                        $senderId = $chat->craftsman_id;
                    }

                    \Log::info('Admin replying to chat', [
                        'admin_id' => $adminUser->id,
                        'chat_id' => $chat->id,
                        'sender_id' => $senderId,
                        'craftsman_id' => $chat->craftsman_id,
                        'customer_id' => $chat->customer_id,
                    ]);

                    $message = ChatMessage::create([
                        'chat_id' => $chat->id,
                        'sender_id' => $senderId,
                        'message' => $data['message'],
                        'message_type' => 'text',
                    ]);

                    // Update chat
                    $chat->last_message = $data['message'];
                    $chat->last_message_at = now();
                    $chat->craftsman_read = true;
                    $chat->customer_read = false;
                    $chat->save();

                    \Log::info('Admin reply saved', [
                        'message_id' => $message->id,
                        'chat_id' => $chat->id,
                        'sender_id' => $senderId,
                        'admin_id' => $adminUser->id,
                        'craftsman_id' => $chat->craftsman_id,
                        'customer_id' => $chat->customer_id,
                        'message_preview' => substr($data['message'], 0, 50),
                    ]);
                    
                    // Verify message was saved
                    $savedMessage = ChatMessage::find($message->id);
                    \Log::info('Verifying saved message', [
                        'message_exists' => $savedMessage !== null,
                        'message_sender_id' => $savedMessage?->sender_id,
                        'message_chat_id' => $savedMessage?->chat_id,
                    ]);

                    Notification::make()
                        ->title('تم إرسال الرد بنجاح')
                        ->success()
                        ->send();

                    $this->replyMessage = '';
                }),
        ];
    }
}
