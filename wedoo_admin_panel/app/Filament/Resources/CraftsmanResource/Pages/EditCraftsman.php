<?php

namespace App\Filament\Resources\CraftsmanResource\Pages;

use App\Filament\Resources\CraftsmanResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCraftsman extends EditRecord
{
    protected static string $resource = CraftsmanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
