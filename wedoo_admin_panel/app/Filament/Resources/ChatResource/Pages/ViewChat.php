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
                    // If admin is the craftsman in the chat, use admin's ID
                    // Otherwise, if admin is replying to support chat, use craftsman_id (which should be admin)
                    $senderId = $adminUser->id;
                    
                    // For support chats, the admin is usually the craftsman
                    // But if admin is not in the chat, we need to use the craftsman_id
                    if ($adminUser->user_type === 'admin' && $chat->craftsman_id !== $adminUser->id) {
                        // Admin is replying to a chat where they're not the craftsman
                        // This shouldn't happen for support chats, but handle it
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
