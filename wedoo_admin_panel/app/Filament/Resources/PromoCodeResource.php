<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PromoCodeResource\Pages;
use App\Filament\Resources\PromoCodeResource\RelationManagers;
use App\Models\PromoCode;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PromoCodeResource extends Resource
{
    protected static ?string $model = PromoCode::class;

    protected static ?string $navigationIcon = 'heroicon-o-ticket';
    
    protected static ?string $navigationLabel = 'أكواد الخصم';
    
    protected static ?string $modelLabel = 'كود خصم';
    
    protected static ?string $pluralModelLabel = 'أكواد الخصم';
    
    protected static ?string $navigationGroup = 'إدارة التطبيق';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('code')
                    ->label('كود الخصم')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->rules(['regex:/^[A-Z0-9]+$/'])
                    ->helperText('يجب أن يحتوي على أحرف كبيرة وأرقام فقط'),
                Forms\Components\TextInput::make('name')
                    ->label('اسم الكود')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->label('الوصف')
                    ->maxLength(65535)
                    ->columnSpanFull(),
                Forms\Components\Select::make('type')
                    ->label('نوع الخصم')
                    ->options([
                        'percentage' => 'نسبة مئوية',
                        'fixed' => 'مبلغ ثابت',
                    ])
                    ->default('percentage')
                    ->required()
                    ->live(),
                Forms\Components\TextInput::make('value')
                    ->label('قيمة الخصم')
                    ->required()
                    ->numeric()
                    ->suffix(fn (Forms\Get $get): string => $get('type') === 'percentage' ? '%' : 'ج.م'),
                Forms\Components\TextInput::make('minimum_amount')
                    ->label('الحد الأدنى للطلب')
                    ->numeric()
                    ->suffix('ج.م'),
                Forms\Components\TextInput::make('usage_limit')
                    ->label('حد الاستخدام')
                    ->numeric()
                    ->helperText('اتركه فارغاً للاستخدام غير المحدود'),
                Forms\Components\DateTimePicker::make('starts_at')
                    ->label('تاريخ البداية')
                    ->displayFormat('d/m/Y H:i'),
                Forms\Components\DateTimePicker::make('expires_at')
                    ->label('تاريخ الانتهاء')
                    ->displayFormat('d/m/Y H:i'),
                Forms\Components\Toggle::make('is_active')
                    ->label('نشط')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->label('كود الخصم')
                    ->searchable()
                    ->sortable()
                    ->copyable(),
                Tables\Columns\TextColumn::make('name')
                    ->label('اسم الكود')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'percentage' => 'نسبة مئوية',
                        'fixed' => 'مبلغ ثابت',
                    }),
                Tables\Columns\TextColumn::make('value')
                    ->label('القيمة')
                    ->formatStateUsing(function ($record) {
                        return $record->type === 'percentage' 
                            ? $record->value . '%' 
                            : $record->value . ' ج.م';
                    }),
                Tables\Columns\TextColumn::make('minimum_amount')
                    ->label('الحد الأدنى')
                    ->money('EGP')
                    ->sortable(),
                Tables\Columns\TextColumn::make('usage_limit')
                    ->label('حد الاستخدام')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('used_count')
                    ->label('المستخدم')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->label('تاريخ البداية')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('expires_at')
                    ->label('تاريخ الانتهاء')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('نوع الخصم')
                    ->options([
                        'percentage' => 'نسبة مئوية',
                        'fixed' => 'مبلغ ثابت',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط')
                    ->placeholder('الكل')
                    ->trueLabel('نشط')
                    ->falseLabel('غير نشط'),
                Tables\Filters\Filter::make('expired')
                    ->label('منتهي الصلاحية')
                    ->query(fn (Builder $query): Builder => $query->where('expires_at', '<', now())),
                Tables\Filters\Filter::make('active')
                    ->label('نشط حالياً')
                    ->query(fn (Builder $query): Builder => $query->where('is_active', true)
                        ->where(function ($q) {
                            $q->whereNull('starts_at')->orWhere('starts_at', '<=', now());
                        })
                        ->where(function ($q) {
                            $q->whereNull('expires_at')->orWhere('expires_at', '>=', now());
                        })),
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
            ]);
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
            'index' => Pages\ListPromoCodes::route('/'),
            'create' => Pages\CreatePromoCode::route('/create'),
            'edit' => Pages\EditPromoCode::route('/{record}/edit'),
        ];
    }
}
