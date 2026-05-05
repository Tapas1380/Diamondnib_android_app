<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content;
use App\Models\Content_Episode;
use App\Models\Content_Section;
use App\Models\History;
use App\Models\Language;
use App\Models\Reviews;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

// section_type = 1- Home page, 2- AudioBook, 3- Novel
// is_home_screen = 1- Home Screen, 2- Other Screen
// content_type = 1- AudioBook, 2- Novel, 3- Category, 4- Language, 5- Artist 6- Continue_Playing	

class ContentController extends Controller
{
    private $folder_category = "category";
    private $folder_language = "language";
    private $folder_artist = "artist";
    private $folder_user = "user";
    private $folder_content = "content";
    public $common;
    public $page_limit;
    public function __construct()
    {
        try {
            $this->common = new Common();
            $this->page_limit = env('PAGE_LIMIT');
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    private function isSubscriptionActive($user_id)
    {
        if (!$user_id) {
            return false;
        }

        $user = User::where('id', $user_id)->first();
        if (!$user || $user->subscription_active != 1 || !$user->subscription_expiry_date) {
            return false;
        }

        return strtotime($user->subscription_expiry_date) >= strtotime(date('Y-m-d H:i:s'));
    }

    public function get_home_banner(Request $request)
    {
        try {

            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'top_category_id' => 'numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 1;
            $is_home_screen = $request['is_home_screen'];
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            if ($is_home_screen == 1) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->with('content')->orderBy('id', 'desc')->latest()->get();
            } else if ($is_home_screen == 2) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->with('content')->orderBy('id', 'asc')->latest()->get();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (count($data) > 0) {

                $final_data = [];
                for ($i = 0; $i < count($data); $i++) {

                    if ($data[$i]['content'] != null) {

                        $data[$i]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['portrait_img']);
                        $data[$i]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['landscape_img']);
                        $data[$i]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$i]['content']['web_banner_img']);
                        $data[$i]['content']['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['content']['full_novel']);
                        $data[$i]['content']['category_name'] = $this->common->getCategoryName($data[$i]['content']['category_id']);
                        $data[$i]['content']['artist_name'] = $this->common->getArtistName($data[$i]['content']['artist_id']);
                        $data[$i]['content']['language_name'] = $this->common->getLanguageName($data[$i]['content']['language_id']);
                        $data[$i]['content']['avg_rating'] = $this->common->getAvgRating($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['total_episode'] = $this->common->getTotalEpisode($data[$i]['content']['id']);
                        $data[$i]['content']['total_reviews'] = $this->common->getTotalReviews($data[$i]['content']['id']);
                        $data[$i]['content']['total_user_play'] = $this->common->getTotalPlay($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['total_user_play'] = $this->common->getTotalPlay($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content']['content_type'], $data[$i]['content']['id']);

                        $final_data[] = $data[$i]['content'];
                    }
                    unset($data[$i]['content']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $final_data);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_home_section(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'user_id' => 'numeric',
                    'top_category_id' => 'numeric',
                    'page_no' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 1;
            $is_home_screen = $request['is_home_screen'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            if ($is_home_screen == 1) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else if ($is_home_screen == 2) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $offset = $page_no * $total_page - $total_page;

            $more_page = $this->common->more_page($page_no, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['data'] = [];
                    if ($data[$i]['content_type'] == 1 || $data[$i]['content_type'] == 2) {

                        $query = $this->common->content_section_query($user_id, $data[$i]['content_type'], $data[$i]['category_id'], $data[$i]['language_id'], $data[$i]['artist_id'], $data[$i]['order_by_play'], $data[$i]['order_by_upload'], $data[$i]['no_of_content']);
                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 3) {

                        $query = Category::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_category);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 4) {

                        $query = Language::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_language);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 5) {

                        $query = Artist::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_artist);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['user_name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 6) {
                        if ($user_id != 0) {

                            $history = History::where('user_id', $user_id)->where('status', 1)->whereIn('content_type', [1, 2])->where('audiobook_type', '!=', 2)
                                ->orderBy('id', 'desc')->with('content')->get();

                            $query = [];
                            for ($j = 0; $j < count($history); $j++) {

                                if ($history[$j]['content'] != null && isset($history[$j]['content'])) {

                                    $history[$j]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['portrait_img']);
                                    $history[$j]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['landscape_img']);
                                    $history[$j]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $history[$j]['content']['web_banner_img']);
                                    $history[$j]['content']['full_novel'] = $this->common->getBook($this->folder_content, $history[$j]['content']['full_novel']);
                                    $history[$j]['content']['category_name'] = $this->common->getCategoryName($history[$j]['content']['category_id']);
                                    $history[$j]['content']['artist_name'] = $this->common->getArtistName($history[$j]['content']['artist_id']);
                                    $history[$j]['content']['language_name'] = $this->common->getLanguageName($history[$j]['content']['language_id']);
                                    $history[$j]['content']['avg_rating'] = $this->common->getAvgRating($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['total_episode'] = $this->common->getTotalEpisode($history[$j]['content']['id']);
                                    $history[$j]['content']['total_reviews'] = $this->common->getTotalReviews($history[$j]['content']['id']);
                                    $history[$j]['content']['total_user_play'] = $this->common->getTotalPlay($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['stop_time'] = $history[$j]['stop_time'];

                                    $query[] = $history[$j]['content'];
                                }
                            }

                            $data[$i]['data'] = $query;
                        } else {
                            $data[$i]['data'] = [];
                        }
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_audiobook_banner(Request $request)
    {
        try {

            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'top_category_id' => 'numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 2;
            $is_home_screen = $request['is_home_screen'];
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            if ($is_home_screen == 1) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->with('content')->orderBy('id', 'desc')->latest()->get();
            } else if ($is_home_screen == 2) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->with('content')->orderBy('id', 'asc')->latest()->get();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (count($data) > 0) {

                $final_data = [];
                for ($i = 0; $i < count($data); $i++) {

                    if ($data[$i]['content'] != null) {

                        $data[$i]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['portrait_img']);
                        $data[$i]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['landscape_img']);
                        $data[$i]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$i]['content']['web_banner_img']);
                        $data[$i]['content']['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['content']['full_novel']);
                        $data[$i]['content']['category_name'] = $this->common->getCategoryName($data[$i]['content']['category_id']);
                        $data[$i]['content']['artist_name'] = $this->common->getArtistName($data[$i]['content']['artist_id']);
                        $data[$i]['content']['language_name'] = $this->common->getLanguageName($data[$i]['content']['language_id']);
                        $data[$i]['content']['avg_rating'] = $this->common->getAvgRating($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['total_episode'] = $this->common->getTotalEpisode($data[$i]['content']['id']);
                        $data[$i]['content']['total_reviews'] = $this->common->getTotalReviews($data[$i]['content']['id']);
                        $data[$i]['content']['total_user_play'] = $this->common->getTotalPlay($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content']['content_type'], $data[$i]['content']['id']);

                        $final_data[] = $data[$i]['content'];
                    }
                    unset($data[$i]['content']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $final_data);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_audiobook_section(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'user_id' => 'numeric',
                    'top_category_id' => 'numeric',
                    'page_no' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 2;
            $is_home_screen = $request['is_home_screen'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            if ($is_home_screen == 1) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else if ($is_home_screen == 2) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $offset = $page_no * $total_page - $total_page;

            $more_page = $this->common->more_page($page_no, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['data'] = [];
                    if ($data[$i]['content_type'] == 1 || $data[$i]['content_type'] == 2) {

                        $query = $this->common->content_section_query($user_id, $data[$i]['content_type'], $data[$i]['category_id'], $data[$i]['language_id'], $data[$i]['artist_id'], $data[$i]['order_by_play'], $data[$i]['order_by_upload'], $data[$i]['no_of_content']);
                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 3) {

                        $query = Category::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_category);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 4) {

                        $query = Language::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_language);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 5) {

                        $query = Artist::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_artist);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['user_name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 6) {
                        if ($user_id != 0) {

                            $history = History::where('user_id', $user_id)->where('status', 1)->whereIn('content_type', [1, 2])->where('audiobook_type', '!=', 2)
                                ->orderBy('id', 'desc')->with('content')->get();

                            $query = [];
                            for ($j = 0; $j < count($history); $j++) {

                                if ($history[$j]['content'] != null && isset($history[$j]['content'])) {

                                    $history[$j]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['portrait_img']);
                                    $history[$j]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['landscape_img']);
                                    $history[$j]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $history[$j]['content']['web_banner_img']);
                                    $history[$j]['content']['full_novel'] = $this->common->getBook($this->folder_content, $history[$j]['content']['full_novel']);
                                    $history[$j]['content']['category_name'] = $this->common->getCategoryName($history[$j]['content']['category_id']);
                                    $history[$j]['content']['artist_name'] = $this->common->getArtistName($history[$j]['content']['artist_id']);
                                    $history[$j]['content']['language_name'] = $this->common->getLanguageName($history[$j]['content']['language_id']);
                                    $history[$j]['content']['avg_rating'] = $this->common->getAvgRating($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['total_episode'] = $this->common->getTotalEpisode($history[$j]['content']['id']);
                                    $history[$j]['content']['total_reviews'] = $this->common->getTotalReviews($history[$j]['content']['id']);
                                    $history[$j]['content']['total_user_play'] = $this->common->getTotalPlay($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['stop_time'] = $history[$j]['stop_time'];

                                    $query[] = $history[$j]['content'];
                                }
                            }

                            $data[$i]['data'] = $query;
                        } else {
                            $data[$i]['data'] = [];
                        }
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_novel_banner(Request $request)
    {
        try {

            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'top_category_id' => 'numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 3;
            $is_home_screen = $request['is_home_screen'];
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            if ($is_home_screen == 1) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->with('content')->orderBy('id', 'desc')->latest()->get();
            } else if ($is_home_screen == 2) {
                $data = Banner::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->with('content')->orderBy('id', 'asc')->latest()->get();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (count($data) > 0) {

                $final_data = [];
                for ($i = 0; $i < count($data); $i++) {

                    if ($data[$i]['content'] != null) {

                        $data[$i]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['portrait_img']);
                        $data[$i]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['landscape_img']);
                        $data[$i]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$i]['content']['web_banner_img']);
                        $data[$i]['content']['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['content']['full_novel']);
                        $data[$i]['content']['category_name'] = $this->common->getCategoryName($data[$i]['content']['category_id']);
                        $data[$i]['content']['artist_name'] = $this->common->getArtistName($data[$i]['content']['artist_id']);
                        $data[$i]['content']['language_name'] = $this->common->getLanguageName($data[$i]['content']['language_id']);
                        $data[$i]['content']['avg_rating'] = $this->common->getAvgRating($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['total_episode'] = $this->common->getTotalEpisode($data[$i]['content']['id']);
                        $data[$i]['content']['total_reviews'] = $this->common->getTotalReviews($data[$i]['content']['id']);
                        $data[$i]['content']['total_user_play'] = $this->common->getTotalPlay($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content']['content_type'], $data[$i]['content']['id']);

                        $final_data[] = $data[$i]['content'];
                    }
                    unset($data[$i]['content']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $final_data);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_novel_section(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'is_home_screen' => 'required|numeric',
                    'user_id' => 'numeric',
                    'top_category_id' => 'numeric',
                    'page_no' => 'numeric',
                ],
                [
                    'is_home_screen.required' => __('api_msg.is_home_screen_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $section_type = 3;
            $is_home_screen = $request['is_home_screen'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            if ($is_home_screen == 1) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else if ($is_home_screen == 2) {
                $data = Content_Section::where('section_type', $section_type)->where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $offset = $page_no * $total_page - $total_page;

            $more_page = $this->common->more_page($page_no, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['data'] = [];
                    if ($data[$i]['content_type'] == 1 || $data[$i]['content_type'] == 2) {

                        $query = $this->common->content_section_query($user_id, $data[$i]['content_type'], $data[$i]['category_id'], $data[$i]['language_id'], $data[$i]['artist_id'], $data[$i]['order_by_play'], $data[$i]['order_by_upload'], $data[$i]['no_of_content']);
                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 3) {

                        $query = Category::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_category);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 4) {

                        $query = Language::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_language);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 5) {

                        $query = Artist::orderBy('id', 'desc')->get();
                        $this->common->imageNameToUrl($query, 'image', $this->folder_artist);

                        for ($j = 0; $j < count($query); $j++) {
                            $query[$j]['title'] = $query[$j]['user_name'];
                            $query[$j]['portrait_img'] = $query[$j]['image'];
                        }

                        $data[$i]['data'] = $query;
                    } else if ($data[$i]['content_type'] == 6) {
                        if ($user_id != 0) {

                            $history = History::where('user_id', $user_id)->where('status', 1)->whereIn('content_type', [1, 2])->where('audiobook_type', '!=', 2)
                                ->orderBy('id', 'desc')->with('content')->get();

                            $query = [];
                            for ($j = 0; $j < count($history); $j++) {

                                if ($history[$j]['content'] != null && isset($history[$j]['content'])) {

                                    $history[$j]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['portrait_img']);
                                    $history[$j]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $history[$j]['content']['landscape_img']);
                                    $history[$j]['content']['web_banner_img'] = $this->common->getWebImage($this->folder_content, $history[$j]['content']['web_banner_img']);
                                    $history[$j]['content']['full_novel'] = $this->common->getBook($this->folder_content, $history[$j]['content']['full_novel']);
                                    $history[$j]['content']['category_name'] = $this->common->getCategoryName($history[$j]['content']['category_id']);
                                    $history[$j]['content']['artist_name'] = $this->common->getArtistName($history[$j]['content']['artist_id']);
                                    $history[$j]['content']['language_name'] = $this->common->getLanguageName($history[$j]['content']['language_id']);
                                    $history[$j]['content']['avg_rating'] = $this->common->getAvgRating($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['total_episode'] = $this->common->getTotalEpisode($history[$j]['content']['id']);
                                    $history[$j]['content']['total_reviews'] = $this->common->getTotalReviews($history[$j]['content']['id']);
                                    $history[$j]['content']['total_user_play'] = $this->common->getTotalPlay($history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $history[$j]['content']['content_type'], $history[$j]['content']['id']);
                                    $history[$j]['content']['stop_time'] = $history[$j]['stop_time'];

                                    $query[] = $history[$j]['content'];
                                }
                            }

                            $data[$i]['data'] = $query;
                        } else {
                            $data[$i]['data'] = [];
                        }
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_content_section_detail(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'numeric',
                    'section_id' => 'required|numeric',
                    'page_no' => 'numeric',
                ],
                [
                    'section_id.required' => __('api_msg.section_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = isset($request->user_id) ? $request->user_id : 0;
            $section_id = $request['section_id'];
            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            $section = Content_Section::where('id', $section_id)->first();
            if ($section != null && isset($section)) {

                if ($section['content_type'] == 1 || $section['content_type'] == 2) {
                    $data = $this->common->content_section_details_query($user_id, $section['content_type'], $section['category_id'], $section['language_id'], $section['artist_id'], $section['order_by_play'], $section['order_by_upload']);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $offset = $page_no * $total_page - $total_page;

            $more_page = $this->common->more_page($page_no, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($j = 0; $j < count($data); $j++) {

                    $data[$j]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$j]['portrait_img']);
                    $data[$j]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$j]['landscape_img']);
                    $data[$j]['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$j]['web_banner_img']);
                    $data[$j]['full_novel'] = $this->common->getBook($this->folder_content, $data[$j]['full_novel']);
                    $data[$j]['category_name'] = $this->common->getCategoryName($data[$j]['category_id']);
                    $data[$j]['artist_name'] = $this->common->getArtistName($data[$j]['artist_id']);
                    $data[$j]['language_name'] = $this->common->getLanguageName($data[$j]['language_id']);
                    $data[$j]['avg_rating'] = $this->common->getAvgRating($data[$j]['content_type'], $data[$j]['id']);
                    $data[$j]['total_episode'] = $this->common->getTotalEpisode($data[$j]['id']);
                    $data[$j]['total_reviews'] = $this->common->getTotalReviews($data[$j]['id']);
                    $data[$j]['total_user_play'] = $this->common->getTotalPlay($data[$j]['content_type'], $data[$j]['id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_content_detail(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_id' => 'required|numeric',
                    'content_type' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $user_id = isset($request['user_id']) ? $request['user_id'] : 0;

            $content = Content::where('content_type', $content_type)->where('id', $content_id)->where('status', 1)->first();
            if (isset($content) && $content != null) {

                $this->common->imageNameToUrl(array($content), 'portrait_img', $this->folder_content);
                $this->common->imageNameToUrl(array($content), 'landscape_img', $this->folder_content);
                $this->common->videoNameToUrl(array($content), 'full_novel', $this->folder_content);

                $content['web_banner_img'] = $this->common->getWebImage($this->folder_content, $content['web_banner_img']);
                $content['category_name'] = $this->common->getCategoryName($content['category_id']);
                $content['language_name'] = $this->common->getLanguageName($content['language_id']);
                $content['artist_name'] = $this->common->getArtistName($content['artist_id']);
                $content['artist_image'] = $this->common->getArtistImage($content['artist_id']);
                $content['is_follow'] = $this->common->isFollow($user_id, $content['artist_id']);
                $content['artist_followers'] = $this->common->getArtistFollowers($content['artist_id']);
                $content['avg_rating'] = $this->common->getAvgRating($content['content_type'], $content['id']);
                $content['total_episode'] = $this->common->getTotalEpisode($content['id']);
                $content['total_reviews'] = $this->common->getTotalReviews($content['id']);
                $content['total_user_play'] = $this->common->getTotalPlay($content['content_type'], $content['id']);
                $content['is_buy'] = 0;
                if ($content['content_type'] == 2) {
                    $content['is_buy'] = $this->common->isBuy($content['content_type'], 0, $user_id, $content_id, 0);
                    if ($this->isSubscriptionActive($user_id)) {
                        $content['is_buy'] = 1;
                    }
                }
                $content['is_bookmark'] = $this->common->isBookmark($user_id, $content['content_type'], $content['id']);

                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), array($content));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_episode_audio_by_content(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'content_id.required' => __('api_msg.content_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_id = $request['content_id'];
            $user_id = isset($request['user_id']) ? $request['user_id'] : 0;

            $content = Content::where('id', $content_id)->where('status', 1)->first();
            if (isset($content) && $content != null) {

                $page_no = $request->page_no ?? 1;
                $page_size = 0;
                $more_page = false;

               $data = Content_Episode::where('content_id', $content_id)
                ->orderBy('sortable', 'asc')
                ->orderBy('created_at', 'asc');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $offset = $page_no * $total_page - $total_page;

                $more_page = $this->common->more_page($page_no, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                for ($i = 0; $i < count($data); $i++) {

                    $this->common->imageNameToUrl(array($data[$i]), 'image', $this->folder_content);
                    if ($data[$i]['audio_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'audio', $this->folder_content);
                    }
                    if ($data[$i]['video_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'video', $this->folder_content);
                    }
                    $this->common->videoNameToUrl(array($data[$i]), 'book', $this->folder_content);

                    $data[$i]['stop_time'] = $this->common->stopTime($content['content_type'], 1, $user_id, $content_id, $data[$i]['id']);
                    $data[$i]['is_buy'] = $this->common->isBuy($content['content_type'], 1, $user_id, $content_id, $data[$i]['id']);
                    if ($this->isSubscriptionActive($user_id)) {
                        $data[$i]['is_buy'] = 1;
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_episode_video_by_content(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'content_id.required' => __('api_msg.content_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_id = $request['content_id'];
            $user_id = isset($request['user_id']) ? $request['user_id'] : 0;

            $content = Content::where('id', $content_id)->where('status', 1)->first();
            if (isset($content) && $content != null) {

                $page_no = $request->page_no ?? 1;
                $page_size = 0;
                $more_page = false;

                $data = Content_Episode::where('content_id', $content_id)->where('video', '!=', "")->orderBy('sortable', 'asc');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $offset = $page_no * $total_page - $total_page;

                $more_page = $this->common->more_page($page_no, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                for ($i = 0; $i < count($data); $i++) {

                    $this->common->imageNameToUrl(array($data[$i]), 'image', $this->folder_content);
                    if ($data[$i]['audio_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'audio', $this->folder_content);
                    }
                    if ($data[$i]['video_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'video', $this->folder_content);
                    }
                    $this->common->videoNameToUrl(array($data[$i]), 'book', $this->folder_content);

                    $data[$i]['stop_time'] = $this->common->stopTime($content['content_type'], 2, $user_id, $content_id, $data[$i]['id']);
                    $data[$i]['is_buy'] = $this->common->isBuy($content['content_type'], 2, $user_id, $content_id, $data[$i]['id']);
                    if ($this->isSubscriptionActive($user_id)) {
                        $data[$i]['is_buy'] = 1;
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_episode_book_by_content(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'content_id.required' => __('api_msg.content_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_id = $request['content_id'];
            $user_id = isset($request['user_id']) ? $request['user_id'] : 0;

            $content = Content::where('id', $content_id)->where('status', 1)->first();
            if (isset($content) && $content != null) {

                $page_no = $request->page_no ?? 1;
                $page_size = 0;
                $more_page = false;

                $data = Content_Episode::where('content_id', $content_id)->orderBy('sortable', 'asc');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $offset = $page_no * $total_page - $total_page;

                $more_page = $this->common->more_page($page_no, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $page_no, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                for ($i = 0; $i < count($data); $i++) {

                    $this->common->imageNameToUrl(array($data[$i]), 'image', $this->folder_content);
                    if ($data[$i]['audio_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'audio', $this->folder_content);
                    }
                    if ($data[$i]['video_type'] == 1) {
                        $this->common->videoNameToUrl(array($data[$i]), 'video', $this->folder_content);
                    }
                    $this->common->videoNameToUrl(array($data[$i]), 'book', $this->folder_content);

                    $data[$i]['stop_time'] = $this->common->stopTime($content['content_type'], 0, $user_id, $content_id, $data[$i]['id']);
                    $data[$i]['is_buy'] = $this->common->isBuy($content['content_type'], 0, $user_id, $content_id, $data[$i]['id']);
                    if ($this->isSubscriptionActive($user_id)) {
                        $data[$i]['is_buy'] = 1;
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_reviews(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'content_type' => 'required|numeric',
                    'content_id' => 'required|numeric',
                    'comment' => 'required',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                    'comment.required' => __('api_msg.comment_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $content_type = $request['content_type'];
            $content_id = $request['content_id'];
            $comment = $request['comment'];
            $rating = isset($request->rating) ? $request->rating : 0;

            $insert = new Reviews();
            $insert['user_id'] = $user_id;
            $insert['content_type'] = $content_type;
            $insert['content_id'] = $content_id;
            $insert['comment'] = $comment;
            $insert['rating'] = $rating;
            $insert->save();

            return $this->common->API_Response(200, __('api_msg.comment_add_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit_reviews(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'review_id' => 'required|numeric',
                    'rating' => 'required|numeric',
                    'comment' => 'required',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'review_id.required' => __('api_msg.review_id_is_required'),
                    'rating.required' => __('api_msg.rating_is_required'),
                    'comment.required' => __('api_msg.comment_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $review_id = $request['review_id'];
            $rating = $request['rating'];
            $comment = $request['comment'];

            $update = Reviews::where('id', $review_id)->latest()->first();
            if (isset($update) && $update != null) {

                $update['user_id'] = $user_id;
                $update['rating'] = $rating;
                $update['comment'] = $comment;
                $update->save();
                return $this->common->API_Response(200, __('api_msg.review_edit_successfully'));
            }
            return $this->common->API_Response(200, __('api_msg.review_not_found'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function delete_reviews(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'review_id' => 'required|numeric',
                ],
                [
                    'review_id.required' => __('api_msg.review_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $review_id = $request['review_id'];
            Reviews::where('id', $review_id)->delete();

            return $this->common->API_Response(200, __('api_msg.review_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_reviews(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_type' => 'required|numeric',
                    'content_id' => 'required|numeric',
                ],
                [
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_type = $request['content_type'];
            $content_id = $request['content_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Reviews::where('content_type', $content_type)->where('content_id', $content_id)->where('status', 1)->orderBy('id', 'desc')->with('user');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['image'] = "";
                    if ($data[$i]['user'] != null) {
                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
                    }
                    unset($data[$i]['user']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
