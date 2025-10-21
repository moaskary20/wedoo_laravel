<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskTypeController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CraftsmanController;

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

// Auth routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

// Task types routes
Route::get('/task-types/index', [TaskTypeController::class, 'index']);

// Orders routes
Route::post('/orders/create', [OrderController::class, 'create']);
Route::get('/orders/list', [OrderController::class, 'list']);

// Craftsman routes
Route::get('/craftsman/count', [CraftsmanController::class, 'count']);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
