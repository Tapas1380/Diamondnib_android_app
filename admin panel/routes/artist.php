<?php

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

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Artist\LoginController;
use App\Http\Controllers\Artist\DashboardController;
use App\Http\Controllers\Artist\ProfileController;
use App\Http\Controllers\Artist\ChangePasswordController;
use App\Http\Controllers\Artist\AudioBookController;
use App\Http\Controllers\Artist\NovelController;
use App\Http\Controllers\Artist\MusicController;
use App\Http\Controllers\Artist\ReviewsController;
use App\Http\Controllers\Artist\ThreadsController;

Route::group(['middleware' => 'installation'], function () {

    // Login-Logout
    Route::get('login', [LoginController::class, 'login'])->name('artist.login');
    Route::post('login', [LoginController::class, 'save_login'])->name('artist.save.login');
    Route::get('logout', [LoginController::class, 'logout'])->name('artist.logout');

    Route::group(['middleware' => 'authartist'], function () {

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index'])->name('artist.dashboard');
        // Profile
        Route::resource('aprofile', ProfileController::class)->only(['index', 'update']);
        Route::resource('achangepassword', ChangePasswordController::class)->only(['index', 'update']);
        // Audio Book
        Route::resource('aaudiobook', AudioBookController::class)->only(['index', 'store', 'update']);
        Route::get('aaudiobookepisode/{id}', [AudioBookController::class, 'AudioBookIndex'])->name('aaudiobook.episode.index');
        Route::get('aaudiobookepisode/add/{id}', [AudioBookController::class, 'AudioBookAdd'])->name('aaudiobook.episode.add');
        Route::post('aaudiobookepisode/save', [AudioBookController::class, 'AudioBookSave'])->name('aaudiobook.episode.save');
        Route::get('aaudiobookepisode/edit/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookEdit'])->name('aaudiobook.episode.edit');
        Route::post('aaudiobookepisode/update/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookUpdate'])->name('aaudiobook.episode.update');
        Route::post('aaudiobookepisode/sortable', [AudioBookController::class, 'AudioBookSortable'])->name('aaudiobook.episode.sortable');
        // Novel
        Route::resource('anovel', NovelController::class)->only(['index', 'store', 'update']);
        Route::get('anovelepisode/{id}', [NovelController::class, 'NovelIndex'])->name('anovel.episode.index');
        Route::get('anovelepisode/add/{id}', [NovelController::class, 'NovelAdd'])->name('anovel.episode.add');
        Route::post('anovelepisode/save', [NovelController::class, 'NovelSave'])->name('anovel.episode.save');
        Route::get('anovelepisode/edit/{novel_id}/{id}', [NovelController::class, 'NovelEdit'])->name('anovel.episode.edit');
        Route::post('anovelepisode/update/{novel_id}/{id}', [NovelController::class, 'NovelUpdate'])->name('anovel.episode.update');
        Route::post('anovelepisode/sortable', [NovelController::class, 'NovelSortable'])->name('anovel.episode.sortable');
        // Music
        Route::resource('amusic', MusicController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        // Threads
        Route::resource('athreads', ThreadsController::class)->only(['index', 'store']);
        Route::get('acomment/{id}', [ThreadsController::class, 'CommentIndex'])->name('athreads.comment.index');
        // Reviews
        Route::resource('areviews', ReviewsController::class)->only(['index']);

        Route::group(['middleware' => 'checkadmin'], function () {

            // Audio Book
            Route::resource('aaudiobook', AudioBookController::class)->only(['destroy']);
            Route::get('aaudiobookepisode/delete/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookDelete'])->name('aaudiobook.episode.delete');
            // Novel
            Route::resource('anovel', NovelController::class)->only(['destroy']);
            Route::get('anovelepisode/delete/{novel_id}/{id}', [NovelController::class, 'NovelDelete'])->name('anovel.episode.delete');
            // Threads
            Route::resource('athreads', ThreadsController::class)->only(['show']);
            // Music
            Route::resource('amusic', MusicController::class)->only(['show']);
        });
    });
});
