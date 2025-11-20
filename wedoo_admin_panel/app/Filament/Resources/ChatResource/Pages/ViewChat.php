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
                    
                    // Get the other party (customer or craftsman)
                    $recipientId = $adminUser->id === $chat->craftsman_id 
                        ? $chat->customer_id 
                        : $chat->craftsman_id;
                    
                    // If admin is not in the chat, use craftsman_id as admin
                    if ($adminUser->user_type === 'admin') {
                        // Admin can reply to support chats
                        $senderId = $chat->craftsman_id; // Admin user ID
                    } else {
                        $senderId = $adminUser->id;
                    }

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

                    Notification::make()
                        ->title('تم إرسال الرد بنجاح')
                        ->success()
                        ->send();

                    $this->replyMessage = '';
                }),
        ];
    }
}
