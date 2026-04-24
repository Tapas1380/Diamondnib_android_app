<?php

namespace App\Http\Controllers\Artist;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Content;
use App\Models\Music;
use App\Models\Threads;
use Exception;

class DashboardController extends Controller
{
    private $folder_content = "content";
    private $folder_music = "music";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $artist = Artist_Data();
            // Top Card
            $params['AudioBookCount'] = Content::where('artist_id', $artist['id'])->where('content_type', 1)->count();
            $params['NovelCount'] = Content::where('artist_id', $artist['id'])->where('content_type', 2)->count();
            $params['MusicCount'] = Music::where('artist_id', $artist['id'])->count();
            $params['ThreadsCount'] = Threads::where('user_type', 2)->where('user_id', $artist['id'])->count();

            // Most Play AudioBook/ Novel/ Music
            $params['most_play_audiobook'] = Content::where('artist_id', $artist['id'])->where('content_type', 1)->where('status', 1)->orderBy('total_played', 'desc')->take(5)->get();
            $params['most_play_novel'] = Content::where('artist_id', $artist['id'])->where('content_type', 2)->where('status', 1)->orderBy('total_played', 'desc')->take(5)->get();
            $params['most_play_music'] = Music::where('artist_id', $artist['id'])->where('status', 1)->orderBy('total_played', 'desc')->take(5)->get();
            $this->common->imageNameToUrl($params['most_play_audiobook'], 'portrait_img', $this->folder_content);
            $this->common->imageNameToUrl($params['most_play_novel'], 'portrait_img', $this->folder_content);
            $this->common->imageNameToUrl($params['most_play_music'], 'portrait_img', $this->folder_music);

            return view('artist.dashboard', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
