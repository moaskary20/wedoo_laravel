<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            [
                'key' => 'app_name',
                'value' => 'ويدو',
                'type' => 'string',
                'description' => 'اسم التطبيق',
            ],
            [
                'key' => 'app_description',
                'value' => 'منصة ويدو للخدمات المنزلية',
                'type' => 'string',
                'description' => 'وصف التطبيق',
            ],
            [
                'key' => 'contact_phone',
                'value' => '01012345678',
                'type' => 'string',
                'description' => 'رقم الهاتف للتواصل',
            ],
            [
                'key' => 'contact_email',
                'value' => 'info@wedoo.com',
                'type' => 'string',
                'description' => 'البريد الإلكتروني للتواصل',
            ],
            [
                'key' => 'commission_rate',
                'value' => '10',
                'type' => 'number',
                'description' => 'نسبة العمولة (%)',
            ],
            [
                'key' => 'min_order_amount',
                'value' => '50',
                'type' => 'number',
                'description' => 'الحد الأدنى لمبلغ الطلب',
            ],
            [
                'key' => 'max_order_amount',
                'value' => '10000',
                'type' => 'number',
                'description' => 'الحد الأقصى لمبلغ الطلب',
            ],
            [
                'key' => 'working_hours_start',
                'value' => '08:00',
                'type' => 'time',
                'description' => 'ساعة بداية العمل',
            ],
            [
                'key' => 'working_hours_end',
                'value' => '22:00',
                'type' => 'time',
                'description' => 'ساعة نهاية العمل',
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
                'description' => 'وضع الصيانة',
            ],
            [
                'key' => 'registration_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'description' => 'تفعيل التسجيل',
            ],
            [
                'key' => 'notifications_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'description' => 'تفعيل الإشعارات',
            ],
        ];

        foreach ($settings as $setting) {
            Setting::create($setting);
        }

        $this->command->info('تم إنشاء الإعدادات بنجاح');
    }
}
