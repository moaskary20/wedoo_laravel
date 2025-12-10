<x-filament-panels::page>
    <form wire:submit="save">
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
    
    @if ($errors->any())
        <div class="mt-4">
            <x-filament::notification type="danger">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </x-filament::notification>
        </div>
    @endif
</x-filament-panels::page>

