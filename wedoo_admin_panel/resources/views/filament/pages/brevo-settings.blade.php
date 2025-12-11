<x-filament-panels::page>
    <form wire:submit="save">
        @php
            // Ensure $errors variable exists for Filament forms
            $errors = $errors ?? \Illuminate\Support\Facades\View::shared('errors', new \Illuminate\Support\ViewErrorBag);
        @endphp
        
        {{ $this->form }}
        
        <div class="flex justify-end gap-4 mt-6">
            <x-filament::button 
                type="button" 
                color="info" 
                wire:click="testEmail" 
                wire:confirm="هل تريد إرسال إيميل تجريبي؟"
                icon="heroicon-o-paper-airplane">
                اختبار الإيميل
            </x-filament::button>
            <x-filament::button type="submit" color="success" icon="heroicon-o-check">
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>

