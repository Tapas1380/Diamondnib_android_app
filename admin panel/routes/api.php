<?php

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\MusicController;
use App\Http\Controllers\Api\ThreadsController;
use App\Http\Controllers\Api\MetaCapiController;

Route::group(['middleware' => 'apipurchasecode'], function () {

    // ---------------- UsersController ----------------
    Route::post('login', [UserController::class, 'login']);
    Route::post('logout', [UserController::class, 'logout']);
    Route::post('get_profile', [UserController::class, 'get_profile']);
    Route::post('update_profile', [UserController::class, 'update_profile']);
    Route::post('forgot_password', [UserController::class, 'forgot_password']);
    Route::post('verify_reset_code', [UserController::class, 'verify_reset_code']);

    // ---------------- Meta CAPI Tracking ----------------
    Route::post('meta_capi/track', [MetaCapiController::class, 'track']);

    // ---------------- HomeController ----------------
    Route::post('general_setting', [HomeController::class, 'general_setting']);
    Route::post('get_payment_option', [HomeController::class, 'get_payment_option']);
    Route::post('get_pages', [HomeController::class, 'get_pages']);
    Route::post('get_avatar', [HomeController::class, 'get_avatar']);
    Route::post('get_package', [HomeController::class, 'get_package']);
    Route::post('get_category', [HomeController::class, 'get_category']);
    Route::post('get_language', [HomeController::class, 'get_language']);
    Route::post('get_artist_detail', [HomeController::class, 'get_artist_detail']);
    Route::post('add_remove_follow', [HomeController::class, 'add_remove_follow']);
    Route::post('add_content_to_history', [HomeController::class, 'add_content_to_history']);
    Route::post('remove_content_to_history', [HomeController::class, 'remove_content_to_history']);
    Route::post('search_content', [HomeController::class, 'search_content']);
    Route::post('add_content_play', [HomeController::class, 'add_content_play']);
    Route::post('get_content_by_artist', [HomeController::class, 'get_content_by_artist']);
    Route::post('get_music_by_artist', [HomeController::class, 'get_music_by_artist']);
    Route::post('get_threads_by_artist', [HomeController::class, 'get_threads_by_artist']);
    Route::post('get_notification', [HomeController::class, 'get_notification']);
    Route::post('read_notification', [HomeController::class, 'read_notification']);
    Route::post('add_transaction', [HomeController::class, 'add_transaction']);
    Route::post('buy_content_episode', [HomeController::class, 'buy_content_episode']);
    Route::post('get_artist_suggestion_list', [HomeController::class, 'get_artist_suggestion_list']);
    Route::post('get_threads_by_user', [HomeController::class, 'get_threads_by_user']);
    Route::post('get_content_by_category', [HomeController::class, 'get_content_by_category']);
    Route::post('get_content_by_language', [HomeController::class, 'get_content_by_language']);
    Route::post('get_transaction_list', [HomeController::class, 'get_transaction_list']);
    Route::post('get_wallet_transaction_list', [HomeController::class, 'get_wallet_transaction_list']);
    Route::post('get_earn_coin', [HomeController::class, 'get_earn_coin']);
    Route::post('get_earn_coin_transaction', [HomeController::class, 'get_earn_coin_transaction']);
    Route::post('get_earn_coin_transaction_list', [HomeController::class, 'get_earn_coin_transaction_list']);
    Route::post('add_remove_bookmark', [HomeController::class, 'add_remove_bookmark']);
    Route::post('get_bookmark_list', [HomeController::class, 'get_bookmark_list']);

    // ---------------- ContentController ----------------
    Route::post('get_home_banner', [ContentController::class, 'get_home_banner']);
    Route::post('get_home_section', [ContentController::class, 'get_home_section']);
    Route::post('get_audiobook_banner', [ContentController::class, 'get_audiobook_banner']);
    Route::post('get_audiobook_section', [ContentController::class, 'get_audiobook_section']);
    Route::post('get_novel_banner', [ContentController::class, 'get_novel_banner']);
    Route::post('get_novel_section', [ContentController::class, 'get_novel_section']);
    Route::post('get_content_section_detail', [ContentController::class, 'get_content_section_detail']);
    Route::post('get_content_detail', [ContentController::class, 'get_content_detail']);
    Route::post('get_episode_audio_by_content', [ContentController::class, 'get_episode_audio_by_content']);
    Route::post('get_episode_video_by_content', [ContentController::class, 'get_episode_video_by_content']);
    Route::post('get_episode_book_by_content', [ContentController::class, 'get_episode_book_by_content']);
    Route::post('add_reviews', [ContentController::class, 'add_reviews']);
    Route::post('edit_reviews', [ContentController::class, 'edit_reviews']);
    Route::post('delete_reviews', [ContentController::class, 'delete_reviews']);
    Route::post('get_reviews', [ContentController::class, 'get_reviews']);

    // ---------------- MusicController ----------------
    Route::post('get_music_section', [MusicController::class, 'get_music_section']);
    Route::post('get_music_section_detail', [MusicController::class, 'get_music_section_detail']);

    // ---------------- ThreadsController ----------------
    Route::post('get_threads_list', [ThreadsController::class, 'get_threads_list']);
    Route::post('add_remove_like_dislike', [ThreadsController::class, 'add_remove_like_dislike']);
    Route::post('add_comment', [ThreadsController::class, 'add_comment']);
    Route::post('edit_comment', [ThreadsController::class, 'edit_comment']);
    Route::post('delete_comment', [ThreadsController::class, 'delete_comment']);
    Route::post('get_comment', [ThreadsController::class, 'get_comment']);
    Route::post('get_reply_comment', [ThreadsController::class, 'get_reply_comment']);
    Route::post('upload_threads', [ThreadsController::class, 'upload_threads']);
    Route::post('delete_threads', [ThreadsController::class, 'delete_threads']);
});
