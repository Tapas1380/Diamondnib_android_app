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

use App\Http\Controllers\Admin\AdmobSettingController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Artisan;
use App\Http\Controllers\Admin\LoginController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\LanguageController;
use App\Http\Controllers\Admin\PageController;
use App\Http\Controllers\Admin\ProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\ArtistController;
use App\Http\Controllers\Admin\AudioBookBannerController;
use App\Http\Controllers\Admin\AudioBookController;
use App\Http\Controllers\Admin\NovelController;
use App\Http\Controllers\Admin\MusicController;
use App\Http\Controllers\Admin\SettingController;
use App\Http\Controllers\Admin\PackageController;
use App\Http\Controllers\Admin\PaymentController;
use App\Http\Controllers\Admin\TransactionController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\ReviewsController;
use App\Http\Controllers\Admin\MusicSectionController;
use App\Http\Controllers\Admin\SectionController;
use App\Http\Controllers\Admin\SystemSettingController;
use App\Http\Controllers\Admin\AudioBookSectionController;
use App\Http\Controllers\Admin\BannerController;
use App\Http\Controllers\Admin\EarningSettingController;
use App\Http\Controllers\Admin\NovelBannerController;
use App\Http\Controllers\Admin\NovelSectionController;
use App\Http\Controllers\Admin\ThreadsController;
use App\Http\Controllers\Admin\WalletController;
use App\Http\Controllers\Admin\AvatarController;
use App\Http\Controllers\Admin\FaceBookAdsSettingController;

// Artisan
Route::get('artisan', function () {

    Artisan::call('config:clear');
    Artisan::call('config:cache');
    Artisan::call('cache:clear');
    Artisan::call('view:clear');
    Artisan::call('route:clear');
    return "<h1>All Config Cache Clear Successfully.</h1>";
});
// Version
Route::get('version', function () {
    return "<h1>
        <li>PHP : " . phpversion() . "</li>
        <li>Laravel : " . app()->version() . "</li>
    </h1>";
});

Route::group(['middleware' => 'installation'], function () {

    // Login-Logout
    Route::get('login', [LoginController::class, 'login'])->name('admin.login');
    Route::post('login', [LoginController::class, 'save_login'])->name('admin.save.login');
    Route::get('logout', [LoginController::class, 'logout'])->name('admin.logout');
    // Chunk
    Route::any('audio/saveChunk', [AudioBookController::class, 'saveChunk']);
    Route::any('video/saveChunk', [AudioBookController::class, 'saveChunk']);
    Route::any('novel/saveChunk', [NovelController::class, 'saveChunk']);
    Route::any('music/saveChunk', [MusicController::class, 'saveChunk']);

    Route::group(['middleware' => 'authadmin'], function () {

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
        // Profile
        Route::resource('profile', ProfileController::class)->only(['index', 'store']);
        Route::post('profile/changepassword', [ProfileController::class, 'ChangePassword'])->name('profile.changepassword');
        // Category
        Route::resource('category', CategoryController::class)->only(['index', 'store', 'update']);
        // Language
        Route::resource('language', LanguageController::class)->only(['index', 'store', 'update']);
        // Page
        Route::resource('page', PageController::class)->only(['index', 'store', 'edit', 'update']);
        // User
        Route::resource('user', UserController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        Route::get('user/wallet/{id}', [UserController::class, 'wallet'])->name('user.wallet');
        // Artist
        Route::resource('artist', ArtistController::class)->only(['index', 'store', 'update']);
        // Audio Book
        Route::resource('audiobook', AudioBookController::class)->only(['index', 'store', 'update', 'show']);
        Route::get('audiobookepisode/{id}', [AudioBookController::class, 'AudioBookIndex'])->name('audiobook.episode.index');
        Route::get('audiobookepisode/add/{id}', [AudioBookController::class, 'AudioBookAdd'])->name('audiobook.episode.add');
        Route::post('audiobookepisode/save', [AudioBookController::class, 'AudioBookSave'])->name('audiobook.episode.save');
        Route::get('audiobookepisode/edit/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookEdit'])->name('audiobook.episode.edit');
        Route::post('audiobookepisode/update/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookUpdate'])->name('audiobook.episode.update');
        Route::post('audiobookepisode/sortable', [AudioBookController::class, 'AudioBookSortable'])->name('audiobook.episode.sortable');
        // Novel
        Route::resource('novel', NovelController::class)->only(['index', 'store', 'update', 'show']);
        Route::get('novelepisode/{id}', [NovelController::class, 'NovelIndex'])->name('novel.episode.index');
        Route::get('novelepisode/add/{id}', [NovelController::class, 'NovelAdd'])->name('novel.episode.add');
        Route::post('novelepisode/save', [NovelController::class, 'NovelSave'])->name('novel.episode.save');
        Route::get('novelepisode/edit/{novel_id}/{id}', [NovelController::class, 'NovelEdit'])->name('novel.episode.edit');
        Route::post('novelepisode/update/{novel_id}/{id}', [NovelController::class, 'NovelUpdate'])->name('novel.episode.update');
        Route::post('novelepisode/sortable', [NovelController::class, 'NovelSortable'])->name('novel.episode.sortable');
        // Music
        Route::resource('music', MusicController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        Route::get('musicstatus', [MusicController::class, 'changeStatus'])->name('music.status');
        // Threads
        Route::resource('threads', ThreadsController::class)->only(['index', 'show']);
        Route::get('comment/{id}', [ThreadsController::class, 'CommentIndex'])->name('threads.comment.index');
        Route::post('commentstatus/{id}', [ThreadsController::class, 'CommentStatus'])->name('threads.comment.status');
        // App Setting
        Route::get('setting', [SettingController::class, 'index'])->name('setting');
        Route::post('setting/app', [SettingController::class, 'app'])->name('setting.app');
        Route::post('setting/currency', [SettingController::class, 'currency'])->name('setting.currency');
        Route::post('smtp/save', [SettingController::class, 'smtpSave'])->name('smtp.save');
        // Earning Setting
        Route::get('earningsetting', [EarningSettingController::class, 'index'])->name('earningsetting');
        Route::post('earningsetting/spinwheelpoint', [EarningSettingController::class, 'spinWheelPoint'])->name('spinwheelpoint');
        Route::post('earningsetting/dailyloginpoint', [EarningSettingController::class, 'dailyLoginPoint'])->name('dailyloginpoint');
        Route::post('earningsetting/getfreecongpoint', [EarningSettingController::class, 'getFreeCongPoint'])->name('getfreecongpoint');
        // System Setting
        Route::get('systemsetting', [SystemSettingController::class, 'index'])->name('system.setting.index');
        Route::post('systemsetting/cleardata', [SystemSettingController::class, 'ClearData'])->name('system.setting.cleardata');
        Route::post('systemsetting/cleandatabase', [SystemSettingController::class, 'CleanDatabase'])->name('system.setting.cleandatabase');
        // Package
        Route::resource('package', PackageController::class)->only(['index', 'create', 'store', 'edit', 'update']);
        // Payment
        Route::resource('payment', PaymentController::class)->only(['index']);
        // Transaction
        Route::resource('transaction', TransactionController::class)->only(['index', 'create', 'store']);
        Route::any('search_user', [TransactionController::class, 'searchUser'])->name('searchUser');
        // Notification
        Route::resource('notification', NotificationController::class)->only(['index', 'create', 'store']);
        // Reviews
        Route::resource('reviews', ReviewsController::class)->only(['index', 'show']);
        // Avatar
        Route::resource('avatar', AvatarController::class)->only(['index', 'store', 'update']);
        // Music Section
        Route::resource('sectionmusic', MusicSectionController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('sectionmusic/data', [MusicSectionController::class, 'GetSectionData'])->name('sectionmusic.content.data');
        Route::post('sectionmusic/edit', [MusicSectionController::class, 'SectionDataEdit'])->name('sectionmusic.content.edit');
        Route::post('sectionmusic/sortable', [MusicSectionController::class, 'SectionSortable'])->name('sectionmusic.content.sortable');
        Route::post('sectionmusic/sortable/save', [MusicSectionController::class, 'SectionSortableSave'])->name('sectionmusic.content.sortable.save');
        // Home Section
        Route::resource('section', SectionController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('section/data', [SectionController::class, 'GetSectionData'])->name('section.content.data');
        Route::post('section/edit', [SectionController::class, 'SectionDataEdit'])->name('section.content.edit');
        Route::post('section/sortable', [SectionController::class, 'SectionSortable'])->name('section.content.sortable');
        Route::post('section/sortable/save', [SectionController::class, 'SectionSortableSave'])->name('section.content.sortable.save');
        // Audio Book Section
        Route::resource('sectionaudiobook', AudioBookSectionController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('sectionaudiobook/data', [AudioBookSectionController::class, 'GetSectionData'])->name('sectionaudiobook.content.data');
        Route::post('sectionaudiobook/edit', [AudioBookSectionController::class, 'SectionDataEdit'])->name('sectionaudiobook.content.edit');
        Route::post('sectionaudiobook/sortable', [AudioBookSectionController::class, 'SectionSortable'])->name('sectionaudiobook.content.sortable');
        Route::post('sectionaudiobook/sortable/save', [AudioBookSectionController::class, 'SectionSortableSave'])->name('sectionaudiobook.content.sortable.save');
        // Novel Section
        Route::resource('sectionnovel', NovelSectionController::class)->only(['index', 'store', 'update', 'show']);
        Route::post('sectionnovel/data', [NovelSectionController::class, 'GetSectionData'])->name('sectionnovel.content.data');
        Route::post('sectionnovel/edit', [NovelSectionController::class, 'SectionDataEdit'])->name('sectionnovel.content.edit');
        Route::post('sectionnovel/sortable', [NovelSectionController::class, 'SectionSortable'])->name('sectionnovel.content.sortable');
        Route::post('sectionnovel/sortable/save', [NovelSectionController::class, 'SectionSortableSave'])->name('sectionnovel.content.sortable.save');
        // Home Banner
        Route::resource('banner', BannerController::class)->only(['index', 'store', 'destroy']);
        Route::post('banner/typebycontent', [BannerController::class, 'typeByContent'])->name('typeByContent');
        Route::post('banner/list', [BannerController::class, 'BannerList'])->name('bannerList');
        // Audio Book Banner
        Route::resource('banneraudiobook', AudioBookBannerController::class)->only(['index', 'store', 'destroy']);
        Route::post('banneraudiobook/typebycontent', [AudioBookBannerController::class, 'typeByContent'])->name('audiobook.typeByContent');
        Route::post('banneraudiobook/list', [AudioBookBannerController::class, 'BannerList'])->name('audiobook.bannerList');
        // Novel Banner
        Route::resource('bannernovel', NovelBannerController::class)->only(['index', 'store', 'destroy']);
        Route::post('bannernovel/typebycontent', [NovelBannerController::class, 'typeByContent'])->name('novel.typeByContent');
        Route::post('bannernovel/list', [NovelBannerController::class, 'BannerList'])->name('novel.bannerList');
        // Wallet
        Route::resource('wallet', WalletController::class)->only(['index']);
        Route::get('wallettransaction/{id}', [WalletController::class, 'WalletTransaction'])->name('wallet.transaction');
        // Admob
        Route::resource('admob', AdmobSettingController::class)->only(['index']);
        Route::post('admob/android', [AdmobSettingController::class, 'admobAndroid'])->name('admob.android');
        Route::post('admob/ios', [AdmobSettingController::class, 'admobIos'])->name('admob.ios');
        // FaceBook Ads
        Route::resource('fbads', FaceBookAdsSettingController::class)->only(['index']);
        Route::post('fbads/android', [FaceBookAdsSettingController::class, 'facebookadAndroid'])->name('fbads.android');
        Route::post('fbads/ios', [FaceBookAdsSettingController::class, 'facebookadIos'])->name('fbads.ios');

        Route::group(['middleware' => 'checkadmin'], function () {

            // Category
            Route::resource('category', CategoryController::class)->only(['destroy']);
            // Language
            Route::resource('language', LanguageController::class)->only(['destroy']);
            // User
            Route::resource('user', UserController::class)->only(['destroy']);
            // Artist
            Route::resource('artist', ArtistController::class)->only(['destroy']);
            // Audio Book
            Route::resource('audiobook', AudioBookController::class)->only(['destroy']);
            Route::get('audiobookepisode/delete/{audiobook_id}/{id}', [AudioBookController::class, 'AudioBookDelete'])->name('audiobook.episode.delete');
            // Novel
            Route::resource('novel', NovelController::class)->only(['destroy']);
            Route::get('novelepisode/delete/{novel_id}/{id}', [NovelController::class, 'NovelDelete'])->name('novel.episode.delete');
            // Music
            Route::resource('music', MusicController::class)->only(['show']);
            // System Setting
            Route::get('systemsetting/downloadsqlfile', [SystemSettingController::class, 'DownloadSqlFile'])->name('system.setting.downloadsqlfile');
            // Package
            Route::resource('package', PackageController::class)->only(['destroy']);
            // Payment
            Route::resource('payment', PaymentController::class)->only(['edit', 'update']);
            // Notification
            Route::resource('notification', NotificationController::class)->only(['destroy']);
            Route::get('notifications/setting', [NotificationController::class, 'setting'])->name('notification.setting');
            Route::post('notifications/setting', [NotificationController::class, 'settingsave'])->name('notification.settingsave');
            // Avatar
            Route::resource('avatar', AvatarController::class)->only(['destroy']);
        });
    });
});
