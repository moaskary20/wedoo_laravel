<?php

namespace App\Filament\Resources\ChatResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MessagesRelationManager extends RelationManager
{
    protected static string $relationship = 'messages';

    protected static ?string $recordTitleAttribute = 'message';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('sender_id')
                    ->label('المرسل')
                    ->relationship('sender', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Forms\Components\Textarea::make('message')
                    ->label('الرسالة')
                    ->required()
                    ->maxLength(1000),
                Forms\Components\Select::make('message_type')
                    ->label('نوع الرسالة')
                    ->options([
                        'text' => 'نص',
                        'image' => 'صورة',
                        'file' => 'ملف',
                    ])
                    ->default('text')
                    ->required(),
                Forms\Components\TextInput::make('file_path')
                    ->label('مسار الملف')
                    ->nullable(),
                Forms\Components\Toggle::make('is_read')
                    ->label('تم القراءة')
                    ->default(false),
                Forms\Components\DateTimePicker::make('read_at')
                    ->label('وقت القراءة')
                    ->nullable(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('message')
            ->columns([
                Tables\Columns\TextColumn::make('sender.name')
                    ->label('المرسل')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('message')
                    ->label('الرسالة')
                    ->limit(100)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        if (strlen($state) <= 100) {
                            return null;
                        }
                        return $state;
                    }),
                Tables\Columns\BadgeColumn::make('message_type')
                    ->label('النوع')
                    ->colors([
                        'primary' => 'text',
                        'success' => 'image',
                        'warning' => 'file',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'text' => 'نص',
                        'image' => 'صورة',
                        'file' => 'ملف',
                    }),
                Tables\Columns\IconColumn::make('is_read')
                    ->label('تم القراءة')
                    ->boolean(),
                Tables\Columns\TextColumn::make('read_at')
                    ->label('وقت القراءة')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإرسال')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('message_type')
                    ->label('نوع الرسالة')
                    ->options([
                        'text' => 'نص',
                        'image' => 'صورة',
                        'file' => 'ملف',
                    ]),
                Tables\Filters\TernaryFilter::make('is_read')
                    ->label('حالة القراءة')
                    ->placeholder('جميع الرسائل')
                    ->trueLabel('مقروءة')
                    ->falseLabel('غير مقروءة'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
