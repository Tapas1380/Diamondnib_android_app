<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\User;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\Package;
use App\Models\Common;
use App\Models\Content;
use App\Models\Content_Episode;
use App\Models\Follow;
use App\Models\Language;
use App\Models\Music;
use App\Models\Page;
use App\Models\Threads;
use Illuminate\Support\Facades\URL;
use Exception;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    private $folder_content = "content";
    private $folder_music = "music";
    private $folder_language = "language";
    private $folder_artist = "artist";
    private $folder_threads = "threads";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {
            // Top Card
            $params['UserCount'] = User::count();
            $params['ArtistCount'] = Artist::count();
            $params['AudioBookCount'] = Content::where('content_type', 1)->count();
            $params['NovelCount'] = Content::where('content_type', 2)->count();
            $params['MusicCount'] = Music::count();

            // Second Card
            $params['EarningsCount'] = Transaction::sum('price');
            $params['CurrentMounthCount'] = Transaction::whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->sum('price');
            $params['PackageCount'] = Package::count();
            $params['CategoryCount'] = Category::count();
            $params['ThreadsCount'] = Threads::count();

            // User Statistice
            $user_data = [];
            $user_month = [];
            $d = cal_days_in_month(CAL_GREGORIAN, date('m'), date('Y'));

            for ($i = 1; $i < 13; $i++) {
                $Sum = User::whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->count();
                $user_data['sum'][] = (int) $Sum;
            }
            for ($i = 1; $i <= $d; $i++) {

                $Sum = User::whereYear('created_at', date('Y'))->whereMonth('created_at', date('m'))->whereDay('created_at', $i)->count();
                $user_month['sum'][] = (int) $Sum;
            }
            $params['user_year'] = json_encode($user_data);
            $params['user_month'] = json_encode($user_month);

            // Plan Earning Statistice
            $subscription = Package::get();
            $pack_data = [];
            foreach ($subscription as $row) {

                $sum = array();
                for ($i = 1; $i < 13; $i++) {

                    $Sum = Transaction::where('package_id', $row->id)->whereYear('created_at', date('Y'))->whereMonth('created_at', $i)->sum('price');
                    $sum[] = (int) $Sum;
                }
                $pack_data['label'][] = $row->name;
                $pack_data['sum'][] = $sum;
            }
            $params['package'] = json_encode($pack_data);

            // Most Play AudioBook/ Novel/ Music
            $get_audio_total_play = Content_Episode::where('total_audio_played', '!=', 0)->orderBy('total_audio_played', 'desc')->latest()->get();
            $get_novel_total_play = Content_Episode::where('total_book_played', '!=', 0)->orderBy('total_book_played', 'desc')->latest()->get();
            $content_ids = [];
            $content_novel_ids = [];
            for ($i = 0; $i < count($get_audio_total_play); $i++) {

                if (!in_array($get_audio_total_play[$i]['content_id'], $content_ids)) {

                    $content_ids[] = $get_audio_total_play[$i]['content_id'];
                    if (count($content_ids) > 5) {
                        break;
                    }
                }
            }
            for ($i = 0; $i < count($get_novel_total_play); $i++) {

                if (!in_array($get_novel_total_play[$i]['content_id'], $content_novel_ids)) {

                    $content_novel_ids[] = $get_novel_total_play[$i]['content_id'];
                    if (count($content_novel_ids) > 5) {
                        break;
                    }
                }
            }

            $params['most_play_audiobook'] = Content::whereIn('id', $content_ids)->where('content_type', 1)->where('status', 1)->take(5)->get();
            $params['most_play_novel'] = Content::whereIn('id', $content_novel_ids)->where('content_type', 2)->where('status', 1)->orderBy('total_played', 'desc')->take(5)->get();

            for ($i = 0; $i < count($params['most_play_audiobook']); $i++) {
                $params['most_play_audiobook'][$i]['total_played'] = $this->common->getTotalPlay($params['most_play_audiobook'][$i]['content_type'], $params['most_play_audiobook'][$i]['id']);
            }
            for ($i = 0; $i < count($params['most_play_novel']); $i++) {
                $params['most_play_novel'][$i]['total_played'] = $this->common->getTotalPlay($params['most_play_novel'][$i]['content_type'], $params['most_play_novel'][$i]['id']);
            }

            $params['most_play_music'] = Music::where('status', 1)->orderBy('total_played', 'desc')->take(5)->get();
            $this->common->imageNameToUrl($params['most_play_audiobook'], 'portrait_img', $this->folder_content);
            $this->common->imageNameToUrl($params['most_play_novel'], 'portrait_img', $this->folder_content);
            $this->common->imageNameToUrl($params['most_play_music'], 'portrait_img', $this->folder_music);

            // Best Language
            $params['best_language'] = Language::orderBy('id', 'desc')->take(8)->get();
            $this->common->imageNameToUrl($params['best_language'], 'image', $this->folder_language);

            // Latest Threads
            $params['latest_threads'] = Threads::orderBy('id', 'desc')->take(6)->get();
            $this->common->imageNameToUrl($params['latest_threads'], 'image', $this->folder_threads);

            // Most Famous Artist
            $params['top_artist'] = [];
            $subscrib_artist = Follow::select(DB::raw("count(*) as total_count"), 'artist_id')->where('status', 1)
                ->groupBy('artist_id')->orderBy('total_count', 'desc')->with('artist')->get();
            $q = 0;
            for ($i = 0; $i < count($subscrib_artist); $i++) {
                if ($subscrib_artist[$i]['artist'] != null) {

                    $this->common->imageNameToUrl(array($subscrib_artist[$i]['artist']), 'image', $this->folder_artist);

                    $params['top_artist'][] = $subscrib_artist[$i];
                    $q = $q + 1;
                    if ($q == 10) {
                        break;
                    }
                }
            }

            return view('admin.dashboard', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function Page()
    {
        try {
            $currentURL = URL::current();

            $link_array = explode('/', $currentURL);
            $page = end($link_array);

            $params['result'] = Page::where('page_name', $page)->first();
            if (isset($params['result'])) {

                $params['settings'] = settingData();

                return view('page', $params);
            } else {
                return view('errors.404');
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
