<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Api\PayUController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Page
Route::group(['middleware' => 'installation'], function () {
    Route::get('pages/{page_name}', [DashboardController::class, 'Page'])->name('admin.pages');
    // routes/web.php
    Route::post('/payu/success', [PayUController::class, 'handleSuccess']);
    Route::post('/payu/failure', [PayUController::class, 'handleFailure']);
    Route::get('/payu/status/{txnid}', [PayUController::class, 'status']);
});
