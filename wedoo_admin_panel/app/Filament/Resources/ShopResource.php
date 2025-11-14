<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ShopResource\Pages;
use App\Filament\Resources\ShopResource\RelationManagers;
use App\Models\Shop;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class ShopResource extends Resource
{
    protected static ?string $model = Shop::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';
    
    protected static ?string $navigationLabel = 'المحلات';
    
    protected static ?string $modelLabel = 'محل';
    
    protected static ?string $pluralModelLabel = 'المحلات';
    
    protected static ?string $navigationGroup = 'إدارة التطبيق';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('اسم المحل')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('name_en')
                    ->label('اسم المحل بالإنجليزية')
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->label('الوصف')
                    ->maxLength(65535)
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('owner_name')
                    ->label('اسم المالك')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('phone')
                    ->label('رقم الهاتف')
                    ->tel()
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('email')
                    ->label('البريد الإلكتروني')
                    ->email()
                    ->maxLength(255),
                Forms\Components\TextInput::make('address')
                    ->label('العنوان')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('governorate')
                    ->label('الولاية')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('city')
                    ->label('المدينة')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('district')
                    ->label('الحي')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('latitude')
                    ->label('خط العرض')
                    ->maxLength(255),
                Forms\Components\TextInput::make('longitude')
                    ->label('خط الطول')
                    ->maxLength(255),
                Forms\Components\FileUpload::make('image')
                    ->label('صورة المحل')
                    ->image()
                    ->directory('shops'),
                Forms\Components\Repeater::make('gallery')
                    ->label('معرض الصور')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('صورة')
                            ->image()
                            ->directory('shops/gallery'),
                    ])
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('website')
                    ->label('الموقع الإلكتروني')
                    ->url()
                    ->maxLength(255),
                Forms\Components\TextInput::make('facebook')
                    ->label('فيسبوك')
                    ->url()
                    ->maxLength(255),
                Forms\Components\TextInput::make('instagram')
                    ->label('إنستجرام')
                    ->url()
                    ->maxLength(255),
                Forms\Components\TextInput::make('whatsapp')
                    ->label('واتساب')
                    ->tel()
                    ->maxLength(255),
                Forms\Components\Select::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'pending' => 'في الانتظار',
                    ])
                    ->default('pending')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('الصورة')
                    ->circular(),
                Tables\Columns\TextColumn::make('name')
                    ->label('اسم المحل')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('owner_name')
                    ->label('اسم المالك')
                    ->searchable(),
                Tables\Columns\TextColumn::make('phone')
                    ->label('رقم الهاتف')
                    ->searchable(),
                Tables\Columns\TextColumn::make('governorate')
                    ->label('الولاية')
                    ->searchable(),
                Tables\Columns\TextColumn::make('city')
                    ->label('المدينة')
                    ->searchable(),
                Tables\Columns\TextColumn::make('rating')
                    ->label('التقييم')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('rating_count')
                    ->label('عدد التقييمات')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'warning' => 'inactive',
                        'danger' => 'pending',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'pending' => 'في الانتظار',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'pending' => 'في الانتظار',
                    ]),
                Tables\Filters\Filter::make('governorate')
                    ->form([
                        Forms\Components\TextInput::make('governorate')
                            ->label('الولاية'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['governorate'],
                                fn (Builder $query, $governorate): Builder => $query->where('governorate', 'like', "%{$governorate}%"),
                            );
                    }),
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
            'index' => Pages\ListShops::route('/'),
            'create' => Pages\CreateShop::route('/create'),
            'edit' => Pages\EditShop::route('/{record}/edit'),
        ];
    }
}
