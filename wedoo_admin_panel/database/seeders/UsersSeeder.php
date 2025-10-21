<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    public function run(): void
    {
        // إنشاء المستخدمين الإداريين
        User::create([
            'name' => 'أحمد محمد',
            'email' => 'ahmed@wedoo.com',
            'phone' => '01012345678',
            'password' => Hash::make('123456'),
            'user_type' => 'admin',
            'governorate' => 'القاهرة',
            'city' => 'القاهرة',
            'district' => 'المعادي',
            'membership_code' => 'ADM001',
            'status' => 'active',
        ]);

        User::create([
            'name' => 'فاطمة علي',
            'email' => 'fatma@wedoo.com',
            'phone' => '01087654321',
            'password' => Hash::make('123456'),
            'user_type' => 'admin',
            'governorate' => 'الجيزة',
            'city' => 'الجيزة',
            'district' => 'الدقي',
            'membership_code' => 'ADM002',
            'status' => 'active',
        ]);

        // إنشاء العملاء
        $customers = [
            [
                'name' => 'محمد أحمد',
                'email' => 'mohamed@customer.com',
                'phone' => '01011111111',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'مدينة نصر',
            ],
            [
                'name' => 'سارة محمود',
                'email' => 'sara@customer.com',
                'phone' => '01022222222',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'المهندسين',
            ],
            [
                'name' => 'علي حسن',
                'email' => 'ali@customer.com',
                'phone' => '01033333333',
                'governorate' => 'الإسكندرية',
                'city' => 'الإسكندرية',
                'district' => 'سيدي جابر',
            ],
            [
                'name' => 'نور الدين',
                'email' => 'nour@customer.com',
                'phone' => '01044444444',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'الزمالك',
            ],
            [
                'name' => 'مريم سعد',
                'email' => 'mariam@customer.com',
                'phone' => '01055555555',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الهرم',
            ],
        ];

        foreach ($customers as $customer) {
            User::create([
                'name' => $customer['name'],
                'email' => $customer['email'],
                'phone' => $customer['phone'],
                'password' => Hash::make('123456'),
                'user_type' => 'customer',
                'governorate' => $customer['governorate'],
                'city' => $customer['city'],
                'district' => $customer['district'],
                'membership_code' => 'CUS' . rand(1000, 9999),
                'status' => 'active',
            ]);
        }

        // إنشاء الصنايع
        $categories = Category::all();
        $craftsmen = [
            [
                'name' => 'أحمد الصنايعي',
                'email' => 'ahmed@craftsman.com',
                'phone' => '01066666666',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'المعادي',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA001',
            ],
            [
                'name' => 'محمد النجار',
                'email' => 'mohamed@craftsman.com',
                'phone' => '01077777777',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'الدقي',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA002',
            ],
            [
                'name' => 'سعد السباك',
                'email' => 'saad@craftsman.com',
                'phone' => '01088888888',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'مدينة نصر',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA003',
            ],
            [
                'name' => 'حسن الكهربائي',
                'email' => 'hassan@craftsman.com',
                'phone' => '01099999999',
                'governorate' => 'الإسكندرية',
                'city' => 'الإسكندرية',
                'district' => 'سيدي جابر',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA004',
            ],
            [
                'name' => 'عبد الرحمن الميكانيكي',
                'email' => 'abdelrahman@craftsman.com',
                'phone' => '01010101010',
                'governorate' => 'الجيزة',
                'city' => 'الجيزة',
                'district' => 'المهندسين',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA005',
            ],
            [
                'name' => 'محمود الدهان',
                'email' => 'mahmoud@craftsman.com',
                'phone' => '01012121212',
                'governorate' => 'القاهرة',
                'city' => 'القاهرة',
                'district' => 'الزمالك',
                'category_id' => $categories->random()->id,
                'membership_code' => 'CRA006',
            ],
        ];

        foreach ($craftsmen as $craftsman) {
            User::create([
                'name' => $craftsman['name'],
                'email' => $craftsman['email'],
                'phone' => $craftsman['phone'],
                'password' => Hash::make('123456'),
                'user_type' => 'craftsman',
                'governorate' => $craftsman['governorate'],
                'city' => $craftsman['city'],
                'district' => $craftsman['district'],
                'category_id' => $craftsman['category_id'],
                'membership_code' => $craftsman['membership_code'],
                'status' => 'active',
            ]);
        }

        $this->command->info('تم إنشاء المستخدمين بنجاح');
    }
}
