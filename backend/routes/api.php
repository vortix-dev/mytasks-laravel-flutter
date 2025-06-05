<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\TasksController;
use Illuminate\Support\Facades\Route;

Route::post('login',[AuthController::class, 'login']);
Route::post('register',[AuthController::class, 'register']);
Route::post('logout',[AuthController::class, 'logout']);
Route::middleware('auth:sanctum')->apiResource('tasks', TasksController::class);
Route::middleware('auth:sanctum')->post('tasks-up/{task}', [TasksController::class,'update']);
