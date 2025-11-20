<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Filament\Resources\OrderResource\RelationManagers;
use App\Models\Order;
use App\Models\User;
use App\Models\TaskType;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-cart';
    
    protected static ?string $navigationLabel = 'الطلبات';
    
    protected static ?string $modelLabel = 'طلب';
    
    protected static ?string $pluralModelLabel = 'الطلبات';
    
    protected static ?string $navigationGroup = 'إدارة التطبيق';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('customer_id')
                    ->label('الحريف')
                    ->relationship('customer', 'name')
                    ->required()
                    ->searchable()
                    ->preload(),
                Forms\Components\Select::make('craftsman_id')
                    ->label('الصنايعي')
                    ->relationship('craftsman', 'name')
                    ->searchable()
                    ->preload(),
                Forms\Components\Select::make('task_type_id')
                    ->label('نوع المهمة')
                    ->relationship('taskType', 'name')
                    ->required()
                    ->searchable()
                    ->preload(),
                Forms\Components\TextInput::make('title')
                    ->label('عنوان الطلب')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->label('وصف الطلب')
                    ->required()
                    ->maxLength(65535)
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('location')
                    ->label('الموقع')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('governorate')
                    ->label('الولاية')
                    ->maxLength(255),
                Forms\Components\TextInput::make('city')
                    ->label('المدينة')
                    ->maxLength(255),
                Forms\Components\TextInput::make('district')
                    ->label('الحي')
                    ->maxLength(255),
                Forms\Components\TextInput::make('budget')
                    ->label('الميزانية')
                    ->numeric()
                    ->prefix('ج.م'),
                Forms\Components\DateTimePicker::make('preferred_date')
                    ->label('التاريخ المفضل')
                    ->displayFormat('d/m/Y H:i'),
                Forms\Components\Select::make('status')
                    ->label('حالة الطلب')
                    ->options([
                        'awaiting_assignment' => 'جاري قبول الطلب',
                        'pending' => 'قيد المراجعة',
                        'waiting_response' => 'بانتظار موافقة الصنايعي',
                        'accepted' => 'مقبول',
                        'in_progress' => 'قيد التنفيذ',
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغي',
                        'rejected' => 'مرفوض',
                    ])
                    ->default('awaiting_assignment')
                    ->required(),
                Forms\Components\Textarea::make('notes')
                    ->label('ملاحظات')
                    ->maxLength(65535)
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->sortable(),
                Tables\Columns\TextColumn::make('customer.name')
                    ->label('الحريف')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('craftsman.name')
                    ->label('الصنايعي')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('taskType.name')
                    ->label('نوع المهمة')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('title')
                    ->label('عنوان الطلب')
                    ->searchable()
                    ->limit(30)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        if (strlen($state) <= $column->getCharacterLimit()) {
                            return null;
                        }
                        return $state;
                    }),
                Tables\Columns\TextColumn::make('location')
                    ->label('الموقع')
                    ->searchable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('budget')
                    ->label('الميزانية')
                    ->money('EGP')
                    ->sortable(),
                Tables\Columns\TextColumn::make('preferred_date')
                    ->label('التاريخ المفضل')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'awaiting_assignment',
                        'warning' => 'pending',
                        'info' => 'waiting_response',
                        'success' => 'accepted',
                        'info' => 'in_progress',
                        'success' => 'completed',
                        'danger' => 'cancelled',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'awaiting_assignment' => 'جاري قبول الطلب',
                        'pending' => 'قيد المراجعة',
                        'waiting_response' => 'بانتظار موافقة الصنايعي',
                        'accepted' => 'مقبول',
                        'in_progress' => 'قيد التنفيذ',
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغي',
                        'rejected' => 'مرفوض',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('customer')
                    ->label('الحريف')
                    ->relationship('customer', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('craftsman')
                    ->label('الصنايعي')
                    ->relationship('craftsman', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('taskType')
                    ->label('نوع المهمة')
                    ->relationship('taskType', 'name')
                    ->searchable()
                    ->preload(),
                Tables\Filters\SelectFilter::make('status')
                    ->label('حالة الطلب')
                    ->options([
                        'awaiting_assignment' => 'جاري قبول الطلب',
                        'pending' => 'قيد المراجعة',
                        'waiting_response' => 'بانتظار موافقة الصنايعي',
                        'accepted' => 'مقبول',
                        'in_progress' => 'قيد التنفيذ',
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغي',
                        'rejected' => 'مرفوض',
                    ]),
                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('من تاريخ'),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('إلى تاريخ'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('عرض'),
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
            'index' => Pages\ListOrders::route('/'),
            'create' => Pages\CreateOrder::route('/create'),
            'edit' => Pages\EditOrder::route('/{record}/edit'),
        ];
    }
}
