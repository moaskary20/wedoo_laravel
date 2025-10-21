<?php

namespace App\Filament\Resources\CraftsmanResource\Pages;

use App\Filament\Resources\CraftsmanResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCraftsmen extends ListRecords
{
    protected static string $resource = CraftsmanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
