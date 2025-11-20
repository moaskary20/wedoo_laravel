<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskTypeController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CraftsmanController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ShopController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PromoCodeController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\ChatController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

Route::get('/task-types/index', [TaskTypeController::class, 'index']);
Route::get('/categories/list', [CategoryController::class, 'list']);
Route::get('/shops/list', [ShopController::class, 'list']);
Route::get('/shops/show', [ShopController::class, 'show']);
Route::get('/craftsman/count', [CraftsmanController::class, 'count']);

// Support messages (can be accessed without authentication for initial support chat)
Route::get('/chat/messages', [ChatController::class, 'messages']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User routes
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::get('/users/profile', [UserController::class, 'profile']);
    Route::post('/users/update', [UserController::class, 'update']);
    
    // Orders
    Route::post('/orders/create', [OrderController::class, 'create']);
    Route::get('/orders/list', [OrderController::class, 'list']);
    Route::get('/orders/assigned', [OrderController::class, 'assigned']);
    Route::post('/orders/{order}/invite', [OrderController::class, 'invite']);
    Route::post('/orders/{order}/accept', [OrderController::class, 'accept']);
    Route::post('/orders/{order}/reject', [OrderController::class, 'reject']);
    
    // Notifications
    Route::get('/notifications/list', [NotificationController::class, 'list']);
    Route::post('/notifications/send', [NotificationController::class, 'send']);
    
    // Chat
    Route::get('/craftsman/nearby', [CraftsmanController::class, 'nearby']);
    Route::get('/chat/list', [ChatController::class, 'list']);
    Route::post('/chat/send', [ChatController::class, 'send']);
    
    // Promo codes
    Route::post('/promo/verify', [PromoCodeController::class, 'verify']);
    
    // Ratings
    Route::post('/shops/rate', [RatingController::class, 'rate']);
    
    // Settings
    Route::get('/settings/general', [SettingsController::class, 'general']);
    Route::get('/settings/notifications', [SettingsController::class, 'notifications']);
    Route::get('/settings/privacy', [SettingsController::class, 'privacy']);
    Route::get('/settings/support', [SettingsController::class, 'support']);
});
