<?php

namespace App\Filament\Resources\CraftsmanResource\Pages;

use App\Filament\Resources\CraftsmanResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewCraftsman extends ViewRecord
{
    protected static string $resource = CraftsmanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
