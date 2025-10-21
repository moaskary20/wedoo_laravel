<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NotificationResource\Pages;
use App\Filament\Resources\NotificationResource\RelationManagers;
use App\Models\Notification;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class NotificationResource extends Resource
{
    protected static ?string $model = Notification::class;

    protected static ?string $navigationIcon = 'heroicon-o-bell';
    
    protected static ?string $navigationLabel = 'الإشعارات';
    
    protected static ?string $modelLabel = 'إشعار';
    
    protected static ?string $pluralModelLabel = 'الإشعارات';
    
    protected static ?string $navigationGroup = 'إدارة التطبيق';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->required()
                    ->searchable()
                    ->preload(),
                Forms\Components\TextInput::make('title')
                    ->label('عنوان الإشعار')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('message')
                    ->label('نص الإشعار')
                    ->required()
                    ->maxLength(65535)
                    ->columnSpanFull(),
                Forms\Components\Select::make('type')
                    ->label('نوع الإشعار')
                    ->options([
                        'general' => 'عام',
                        'order' => 'طلب',
                        'promotion' => 'عرض',
                        'system' => 'نظام',
                    ])
                    ->default('general')
                    ->required(),
                Forms\Components\KeyValue::make('data')
                    ->label('بيانات إضافية')
                    ->columnSpanFull(),
                Forms\Components\Toggle::make('is_read')
                    ->label('مقروء')
                    ->default(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->limit(50),
                Tables\Columns\TextColumn::make('message')
                    ->label('النص')
                    ->limit(50)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        if (strlen($state) <= $column->getCharacterLimit()) {
                            return null;
                        }
                        return $state;
                    }),
                Tables\Columns\BadgeColumn::make('type')
                    ->label('النوع')
                    ->colors([
                        'primary' => 'general',
                        'success' => 'order',
                        'warning' => 'promotion',
                        'danger' => 'system',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'general' => 'عام',
                        'order' => 'طلب',
                        'promotion' => 'عرض',
                        'system' => 'نظام',
                    }),
                Tables\Columns\IconColumn::make('is_read')
                    ->label('مقروء')
                    ->boolean(),
                Tables\Columns\TextColumn::make('read_at')
                    ->label('تاريخ القراءة')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('user')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('type')
                    ->label('نوع الإشعار')
                    ->options([
                        'general' => 'عام',
                        'order' => 'طلب',
                        'promotion' => 'عرض',
                        'system' => 'نظام',
                    ]),
                Tables\Filters\TernaryFilter::make('is_read')
                    ->label('مقروء')
                    ->placeholder('الكل')
                    ->trueLabel('مقروء')
                    ->falseLabel('غير مقروء'),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->label('تعديل'),
                Tables\Actions\DeleteAction::make()
                    ->label('حذف'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNotifications::route('/'),
            'create' => Pages\CreateNotification::route('/create'),
            'edit' => Pages\EditNotification::route('/{record}/edit'),
        ];
    }
}
