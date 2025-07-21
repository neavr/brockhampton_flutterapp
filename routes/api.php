<?php

use App\Http\Controllers\ProductController;
use App\Http\Controllers\ImageController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('products', ProductController::class);
Route::put('/products/{id}/decrease-stock', [ProductController::class, 'decreaseStock']);
Route::post('/upload-image', [ImageController::class, 'upload']);
// Route::post('/products/{product}', [ProductController::class, 'update']);
Route::post('/products/update/{id}', [ProductController::class, 'updateWithImage']);
