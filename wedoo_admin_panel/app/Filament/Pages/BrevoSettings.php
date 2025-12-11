<?php

namespace App\Filament\Pages;

use Filament\Forms;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Actions;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Mail;

class BrevoSettings extends Page implements HasForms
{
    use InteractsWithForms;
    
    protected static ?string $navigationIcon = 'heroicon-o-envelope';
    
    protected static ?string $slug = 'brevo-settings';
    
    protected static ?string $navigationLabel = 'إعدادات الإيميل';
    
    protected static ?string $title = 'إعدادات الإيميل (Brevo)';
    
    protected static ?string $navigationGroup = 'الإعدادات';
    
    protected static ?int $navigationSort = 1;
    
    protected static bool $shouldRegisterNavigation = true;

    public ?array $data = [];
    
    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('test')
                ->label('اختبار الإيميل')
                ->icon('heroicon-o-paper-airplane')
                ->color('info')
                ->requiresConfirmation()
                ->modalHeading('اختبار إرسال الإيميل')
                ->modalDescription('سيتم إرسال إيميل تجريبي إلى الإيميل المرسل المحدد.')
                ->action(function () {
                    $this->testEmail();
                }),
        ];
    }
    
    protected function getFormActions(): array
    {
        return [
            Forms\Components\Actions\Action::make('save')
                ->label('حفظ الإعدادات')
                ->action('save')
                ->color('success')
                ->icon('heroicon-o-check'),
        ];
    }

    public function mount(): void
    {
        $this->form->fill([
            'mail_mailer' => env('MAIL_MAILER', 'brevo'),
            'brevo_smtp_host' => env('BREVO_SMTP_HOST', 'smtp-relay.brevo.com'),
            'brevo_smtp_port' => env('BREVO_SMTP_PORT', '587'),
            'brevo_smtp_username' => env('BREVO_SMTP_USERNAME', ''),
            'brevo_smtp_password' => env('BREVO_SMTP_PASSWORD', ''),
            'brevo_encryption' => env('BREVO_ENCRYPTION', 'tls'),
            'brevo_from_email' => env('BREVO_FROM_EMAIL', ''),
            'brevo_from_name' => env('BREVO_FROM_NAME', 'WeDoo'),
            'mail_from_address' => env('MAIL_FROM_ADDRESS', ''),
            'mail_from_name' => env('MAIL_FROM_NAME', 'WeDoo'),
        ]);
    }
    
    protected static string $view = 'filament.pages.brevo-settings';

    public function form(Form $form): Form
    {
        return $form
            ->statePath('data')
            ->schema([
                Forms\Components\Section::make('معلومات')
                    ->description('استخدم هذه الصفحة لإدارة إعدادات Brevo لإرسال الإيميلات من التطبيق.')
                    ->schema([
                        Forms\Components\Placeholder::make('info')
                            ->label('')
                            ->content('💡 نصيحة: يمكنك الحصول على SMTP Key من Brevo Dashboard → SMTP & API → SMTP → Generate new SMTP key')
                    ])
                    ->collapsible()
                    ->collapsed(),
                
                Forms\Components\Section::make('إعدادات Brevo الأساسية')
                    ->description('قم بإدخال بيانات Brevo SMTP لإرسال الإيميلات. يمكنك الحصول على SMTP Key من Brevo Dashboard → SMTP & API → SMTP')
                    ->icon('heroicon-o-envelope')
                    ->schema([
                        Forms\Components\Select::make('mail_mailer')
                            ->label('نوع Mailer')
                            ->options([
                                'brevo' => 'Brevo',
                                'smtp' => 'SMTP',
                            ])
                            ->default('brevo')
                            ->required()
                            ->columnSpanFull(),
                        
                        Forms\Components\TextInput::make('brevo_smtp_host')
                            ->label('SMTP Host')
                            ->default('smtp-relay.brevo.com')
                            ->required()
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('brevo_smtp_port')
                            ->label('SMTP Port')
                            ->default('587')
                            ->numeric()
                            ->required()
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('brevo_smtp_username')
                            ->label('SMTP Username (إيميل Brevo)')
                            ->email()
                            ->required()
                            ->helperText('استخدم إيميل Brevo الخاص بك')
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('brevo_smtp_password')
                            ->label('SMTP Password (SMTP Key)')
                            ->password()
                            ->required()
                            ->helperText('SMTP Key من Brevo Dashboard (يبدأ بـ xsmtpib-...)')
                            ->revealable()
                            ->columnSpan(1),
                        
                        Forms\Components\Select::make('brevo_encryption')
                            ->label('التشفير')
                            ->options([
                                'tls' => 'TLS',
                                'ssl' => 'SSL',
                            ])
                            ->default('tls')
                            ->required()
                            ->columnSpan(1),
                    ])
                    ->columns(2),
                
                Forms\Components\Section::make('إعدادات المرسل')
                    ->description('إعدادات الإيميل المرسل. يجب أن يكون الإيميل مفعّل في Brevo (Senders & IP)')
                    ->icon('heroicon-o-user')
                    ->schema([
                        Forms\Components\TextInput::make('brevo_from_email')
                            ->label('إيميل المرسل')
                            ->email()
                            ->required()
                            ->helperText('يجب أن يكون هذا الإيميل مفعّل في Brevo (Senders & IP)')
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('brevo_from_name')
                            ->label('اسم المرسل')
                            ->default('WeDoo')
                            ->required()
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('mail_from_address')
                            ->label('MAIL_FROM_ADDRESS')
                            ->email()
                            ->required()
                            ->helperText('نفس إيميل المرسل')
                            ->columnSpan(1),
                        
                        Forms\Components\TextInput::make('mail_from_name')
                            ->label('MAIL_FROM_NAME')
                            ->default('WeDoo')
                            ->required()
                            ->columnSpan(1),
                    ])
                    ->columns(2),
            ])
            ->columns(2);
    }

    
    public function testEmail(): void
    {
        try {
            $fromEmail = env('BREVO_FROM_EMAIL', env('MAIL_FROM_ADDRESS', 'noreply@wedoo.com'));
            
            // إرسال إيميل تجريبي
            Mail::raw('هذا إيميل تجريبي من لوحة التحكم. إعدادات Brevo تعمل بشكل صحيح!', function ($message) use ($fromEmail) {
                $message->to($fromEmail)
                    ->subject('اختبار إعدادات Brevo - WeDoo');
            });
            
            Notification::make()
                ->title('نجح')
                ->body('تم إرسال الإيميل التجريبي بنجاح! تحقق من صندوق الوارد.')
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('خطأ')
                ->body('فشل إرسال الإيميل: ' . $e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function save(): void
    {
        // Validate form data first
        $data = $this->form->getState();
        
        $envPath = base_path('.env');
        
        if (!File::exists($envPath)) {
            Notification::make()
                ->title('خطأ')
                ->body('ملف .env غير موجود!')
                ->danger()
                ->send();
            return;
        }
        
        $envContent = File::get($envPath);
        
        // تحديث أو إضافة الإعدادات
        $settings = [
            'MAIL_MAILER' => $data['mail_mailer'],
            'BREVO_SMTP_HOST' => $data['brevo_smtp_host'],
            'BREVO_SMTP_PORT' => $data['brevo_smtp_port'],
            'BREVO_SMTP_USERNAME' => $data['brevo_smtp_username'],
            'BREVO_SMTP_PASSWORD' => $data['brevo_smtp_password'],
            'BREVO_ENCRYPTION' => $data['brevo_encryption'],
            'BREVO_FROM_EMAIL' => $data['brevo_from_email'],
            'BREVO_FROM_NAME' => $data['brevo_from_name'],
            'MAIL_FROM_ADDRESS' => $data['mail_from_address'],
            'MAIL_FROM_NAME' => $data['mail_from_name'],
        ];
        
        foreach ($settings as $key => $value) {
            // Escape special characters in value (especially # which is comment in .env)
            $escapedValue = $value;
            if (preg_match('/[#\s]/', $value)) {
                $escapedValue = '"' . addslashes($value) . '"';
            }
            
            $pattern = "/^{$key}=.*/m";
            $replacement = "{$key}={$escapedValue}";
            
            if (preg_match($pattern, $envContent)) {
                $envContent = preg_replace($pattern, $replacement, $envContent);
            } else {
                // Check if key exists but without value
                if (preg_match("/^{$key}\s*$/m", $envContent)) {
                    $envContent = preg_replace("/^{$key}\s*$/m", $replacement, $envContent);
                } else {
                    // Add at the end if it doesn't exist
                    if (!preg_match("/^{$key}/m", $envContent)) {
                        $envContent .= "\n{$key}={$escapedValue}";
                    }
                }
            }
        }
        
        try {
            File::put($envPath, $envContent);
        } catch (\Exception $e) {
            Notification::make()
                ->title('خطأ')
                ->body('فشل حفظ ملف .env: ' . $e->getMessage())
                ->danger()
                ->send();
            return;
        }
        
        // مسح Cache
        Artisan::call('config:clear');
        Artisan::call('cache:clear');
        Artisan::call('config:cache');
        
        Notification::make()
            ->title('نجح')
            ->body('تم حفظ إعدادات Brevo بنجاح!')
            ->success()
            ->send();
    }

}

