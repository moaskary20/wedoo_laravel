<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Hash;
use Filament\Forms;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    public function form(Forms\Form $form): Forms\Form
    {
        $form = parent::form($form);
        
        // Make password required on create
        $form->getComponent('password')?->required();
        
        return $form;
    }

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Hash password before creating user
        if (!empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        }

        return $data;
    }

}
