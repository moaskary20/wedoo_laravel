<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}
        
        <div class="flex justify-end gap-4 mt-6">
            <x-filament::button type="button" color="info" wire:click="testEmail" icon="heroicon-o-paper-airplane">
                اختبار الإيميل
            </x-filament::button>
            <x-filament::button type="submit" color="success" icon="heroicon-o-check">
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>

