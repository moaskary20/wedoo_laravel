-- Create database
CREATE DATABASE IF NOT EXISTS wedoo_database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use database
USE wedoo_database;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('customer', 'craftsman') DEFAULT 'customer',
    governorate VARCHAR(100),
    city VARCHAR(100),
    district VARCHAR(100),
    membership_code VARCHAR(50) UNIQUE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create task_types table
CREATE TABLE IF NOT EXISTS task_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    category_id INT,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    price_range VARCHAR(100),
    duration VARCHAR(100),
    difficulty ENUM('easy', 'medium', 'hard'),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    task_type_id INT,
    description TEXT,
    location TEXT,
    phone VARCHAR(20),
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_type_id) REFERENCES task_types(id) ON DELETE CASCADE
);

-- Insert sample categories
INSERT INTO categories (name, name_en, description, icon, color) VALUES
('خدمات صيانة المنازل', 'Home Maintenance Services', 'خدمات صيانة وإصلاح المنازل', 'fas fa-home', '#e3f2fd'),
('خدمات التنظيف', 'Cleaning Services', 'خدمات التنظيف الشامل', 'fas fa-broom', '#fce4ec'),
('النقل والخدمات اللوجستية', 'Transportation & Logistics', 'خدمات النقل والشحن', 'fas fa-truck', '#fff3e0'),
('خدمات السيارات', 'Automotive Services', 'صيانة وإصلاح السيارات', 'fas fa-car', '#e8f5e8'),
('خدمات طارئة (عاجلة)', 'Emergency Services', 'خدمات الطوارئ العاجلة', 'fas fa-exclamation-triangle', '#ffebee'),
('خدمات الأسر والعائلات', 'Family Services', 'خدمات العائلات والأطفال', 'fas fa-users', '#f3e5f5'),
('خدمات تقنية', 'Technical Services', 'خدمات تقنية ومعلوماتية', 'fas fa-laptop', '#e0f7fa'),
('خدمات الحديقة', 'Garden Services', 'خدمات الحدائق والزراعة', 'fas fa-seedling', '#e8f5e8');

-- Insert sample task types
INSERT INTO task_types (name, name_en, category_id, description, icon, color, price_range, duration, difficulty) VALUES
-- Category 1: خدمات صيانة المنازل
('صيانة السباكة', 'Plumbing Maintenance', 1, 'إصلاح وصيانة أنظمة السباكة', 'fas fa-wrench', '#e3f2fd', '50-200 دينار تونسي', '1-3 ساعات', 'medium'),
('صيانة الكهرباء', 'Electrical Maintenance', 1, 'إصلاح وصيانة الأنظمة الكهربائية', 'fas fa-bolt', '#fff3e0', '80-300 دينار تونسي', '2-4 ساعات', 'hard'),
('صيانة التكييف', 'AC Maintenance', 1, 'صيانة أجهزة التكييف والتبريد', 'fas fa-snowflake', '#e0f7fa', '100-400 دينار تونسي', '2-3 ساعات', 'medium'),

-- Category 2: خدمات التنظيف
('تنظيف عام للمنزل', 'General House Cleaning', 2, 'تنظيف شامل للمنزل', 'fas fa-broom', '#fce4ec', '80-120 دينار تونسي', '3-4 ساعات', 'easy'),
('تنظيف السجاد', 'Carpet Cleaning', 2, 'تنظيف وغسيل السجاد والموكيت', 'fas fa-brush', '#f3e5f5', '50-100 دينار تونسي', '1-2 ساعة', 'medium'),

-- Category 3: النقل والخدمات اللوجستية
('نقل أثاث', 'Furniture Moving', 3, 'نقل الأثاث والممتلكات', 'fas fa-truck', '#fff3e0', '100-300 دينار تونسي', '2-4 ساعات', 'medium'),
('نقل سريع', 'Express Delivery', 3, 'نقل سريع للطرود والوثائق', 'fas fa-shipping-fast', '#e8f5e8', '20-50 دينار تونسي', '30-60 دقيقة', 'easy'),
('نقل طويل المدى', 'Long Distance Moving', 3, 'نقل لمسافات طويلة', 'fas fa-route', '#f3e5f5', '200-500 دينار تونسي', '4-8 ساعات', 'hard'),

-- Category 5: خدمات طارئة (عاجلة)
('صيانة مكيف هواء', 'Air Conditioner Maintenance', 5, 'صيانة وتنظيف أجهزة التكييف', 'fas fa-snowflake', '#e3f2fd', '100-300 دينار تونسي', '2-3 ساعات', 'medium'),
('تنظيف مكيف هواء', 'Clean Air Conditioner', 5, 'تنظيف أجهزة التكييف والفلاتر', 'fas fa-broom', '#e3f2fd', '60-150 دينار تونسي', '1-2 ساعة', 'easy'),
('إصلاح مكيف هواء', 'Repair Air Conditioner', 5, 'إصلاح أعطال أجهزة التكييف', 'fas fa-wrench', '#e3f2fd', '150-500 دينار تونسي', '2-4 ساعات', 'hard'),
('تركيب مكيف هواء', 'Install Air Conditioner', 5, 'تركيب أجهزة التكييف الجديدة', 'fas fa-plus-circle', '#e3f2fd', '300-800 دينار تونسي', '4-8 ساعات', 'hard'),
('إصلاح ثلاجة', 'Repair Refrigerator', 5, 'إصلاح أعطال الثلاجات وأجهزة التبريد', 'fas fa-ice-cream', '#e3f2fd', '100-400 دينار تونسي', '2-4 ساعات', 'hard');

-- Insert sample user
INSERT INTO users (name, phone, email, password, user_type, governorate, city, district, membership_code) VALUES
('مستخدم تجريبي', '01000690805', 'demo@example.com', 'askary20', 'customer', 'تونس', 'تونس العاصمة', 'المركز', '558206');
