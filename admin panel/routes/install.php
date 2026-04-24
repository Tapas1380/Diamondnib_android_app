<?php
/*
|--------------------------------------------------------------------------
| Install Routes
|--------------------------------------------------------------------------
|
| This route is responsible for handling the intallation process
|
*/

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Install\InstallController;

Route::get('/', [InstallController::class, 'step0'])->name('step0');

Route::get('step1', [InstallController::class, 'step1'])->name('step1');

Route::get('step2', [InstallController::class, 'step2'])->name('step2');
Route::post('purchase_code', [InstallController::class, 'purchase_code'])->name('purchase_code');
Route::get('update_purchase_code', [InstallController::class, 'update_purchase_code'])->name('update_purchase_code');

Route::get('step3', [InstallController::class, 'step3'])->name('step3');
Route::post('database_installation', [InstallController::class, 'database_installation'])->name('install.db');
Route::get('backupdb', [InstallController::class, 'backup_db'])->name('backup_db');

Route::get('step4', [InstallController::class, 'step4'])->name('step4');
Route::get('import_sql', [InstallController::class, 'import_sql'])->name('import_sql');

Route::get('step5', [InstallController::class, 'step5'])->name('step5');
Route::post('system_settings', [InstallController::class, 'system_settings'])->name('system_settings');
