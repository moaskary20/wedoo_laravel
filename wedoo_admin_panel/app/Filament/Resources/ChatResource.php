<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChatResource\Pages;
use App\Filament\Resources\ChatResource\RelationManagers;
use App\Models\Chat;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ChatResource extends Resource
{
    protected static ?string $model = Chat::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = 'المحادثات';

    protected static ?string $modelLabel = 'محادثة';

    protected static ?string $pluralModelLabel = 'المحادثات';

    protected static ?string $navigationGroup = 'التواصل';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('customer_id')
                    ->label('العميل')
                    ->relationship('customer', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Forms\Components\Select::make('craftsman_id')
                    ->label('الصانعي')
                    ->relationship('craftsman', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Forms\Components\Select::make('order_id')
                    ->label('الطلب')
                    ->relationship('order', 'id')
                    ->searchable()
                    ->nullable(),
                Forms\Components\Textarea::make('last_message')
                    ->label('آخر رسالة')
                    ->nullable()
                    ->maxLength(1000),
                Forms\Components\DateTimePicker::make('last_message_at')
                    ->label('وقت آخر رسالة')
                    ->nullable(),
                Forms\Components\Toggle::make('customer_read')
                    ->label('قرأها العميل')
                    ->default(false),
                Forms\Components\Toggle::make('craftsman_read')
                    ->label('قرأها الصانعي')
                    ->default(false),
                Forms\Components\Select::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'closed' => 'مغلق',
                        'blocked' => 'محظور',
                    ])
                    ->default('active')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),
                Tables\Columns\TextColumn::make('customer.name')
                    ->label('العميل')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('craftsman.name')
                    ->label('الصانعي')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('order.id')
                    ->label('رقم الطلب')
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('last_message')
                    ->label('آخر رسالة')
                    ->limit(50)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        if (strlen($state) <= 50) {
                            return null;
                        }
                        return $state;
                    }),
                Tables\Columns\TextColumn::make('last_message_at')
                    ->label('وقت آخر رسالة')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
                Tables\Columns\IconColumn::make('customer_read')
                    ->label('قرأها العميل')
                    ->boolean(),
                Tables\Columns\IconColumn::make('craftsman_read')
                    ->label('قرأها الصانعي')
                    ->boolean(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'warning' => 'closed',
                        'danger' => 'blocked',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشط',
                        'closed' => 'مغلق',
                        'blocked' => 'محظور',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'closed' => 'مغلق',
                        'blocked' => 'محظور',
                    ]),
                Tables\Filters\SelectFilter::make('customer_id')
                    ->label('العميل')
                    ->relationship('customer', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('craftsman_id')
                    ->label('الصانعي')
                    ->relationship('craftsman', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('last_message_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\MessagesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChats::route('/'),
            'create' => Pages\CreateChat::route('/create'),
            'view' => Pages\ViewChat::route('/{record}'),
            'edit' => Pages\EditChat::route('/{record}/edit'),
        ];
    }
}
