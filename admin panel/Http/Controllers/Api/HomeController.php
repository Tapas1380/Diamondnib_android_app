<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Avatar;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content;
use App\Models\Content_Episode;
use App\Models\Content_Play;
use App\Models\Follow;
use App\Models\User;
use App\Models\General_Setting;
use App\Models\History;
use App\Models\Language;
use App\Models\Music;
use App\Models\Notification;
use App\Models\Payment_Option;
use App\Models\Package;
use App\Models\Page;
use App\Models\Read_Notification;
use App\Models\Reward_Coin;
use App\Models\Reward_Transaction;
use App\Models\Threads;
use App\Models\Transaction;
use App\Models\Wallet_Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class HomeController extends Controller
{
    private $folder_app = "app";
    private $folder_avatar = "avatar";
    private $folder_category = "category";
    private $folder_language = "language";
    private $folder_package = "package";
    private $folder_artist = "artist";
    private $folder_content = "content";
    private $folder_user = "user";
    private $folder_music = "music";
    private $folder_threads = "threads";
    private $folder_notification = "notification";
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

    public function general_setting()
    {
        try {

            $list = General_Setting::get();
            foreach ($list as $key => $value) {

                if ($value['key'] == 'app_logo') {
                    $value['value'] = $this->common->getImage($this->folder_app, $value['value']);
                }
                if ($value['key'] == 'home_popup_video') {
                    $value['value'] = $this->common->getImage($this->folder_app, $value['value']);
                }
            }

            return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $list);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_payment_option()
    {
        try {

            $return['status'] = 200;
            $return['message'] = __('api_msg.get_record_successfully');
            $return['result'] = [];

            $Option_data = Payment_Option::get();
            foreach ($Option_data as $key => $value) {
                $return['result'][$value['name']] = $value;
            }

            return $return;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_pages()
    {
        try {

            $return['status'] = 200;
            $return['message'] = __('api_msg.get_record_successfully');
            $return['result'] = [];

            $data = Page::get();
            for ($i = 0; $i < count($data); $i++) {
                $return['result'][$i]['page_name'] = $data[$i]['page_name'];
                $return['result'][$i]['title'] = $data[$i]['title'];
                $return['result'][$i]['url'] = env('APP_URL') . '/public/pages/' . $data[$i]['page_name'];
                $return['result'][$i]['icon'] = $this->common->getImage($this->folder_app, $data[$i]['icon']);
            }
            return $return;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_avatar()
    {
        try {
            $Data = Avatar::latest()->get();
            if (sizeof($Data) > 0) {

                $this->common->imageNameToUrl($Data, 'image', $this->folder_avatar);

                return $this->common->API_Response(200, __('api.get_record_successfully'), $Data);
            } else {
                return $this->common->API_Response(400, __('api.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_package(Request $request)
    {
        try {

            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $data = Package::latest()->get();
            $this->common->imageNameToUrl($data, 'image', $this->folder_package);

            return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_category(Request $request)
    {
        try {
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Category::orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_category);

                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_language(Request $request)
    {
        try {
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Language::orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_language);

                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_artist_detail(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'artist_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'artist_id.required' => __('api_msg.artist_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $artist_id = $request['artist_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $data = Artist::where('id', $artist_id)->where('status', 1)->first();
            if ($data != null && isset($data)) {

                $this->common->imageNameToUrl(array($data), 'image', $this->folder_artist);
                $data['followes'] = $this->common->getArtistFollowers($data['id']);
                $data['is_follow'] = $this->common->isFollow($user_id, $data['id']);

                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), array($data));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_remove_follow(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'artist_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'artist_id.required' => __('api_msg.artist_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $artist_id = $request['artist_id'];

            $follow = Follow::where('user_id', $user_id)->where('artist_id', $artist_id)->where('status', 1)->first();
            if (isset($follow['id']) && $follow != null) {

                Follow::where('id', $follow['id'])->delete();
                return $this->common->API_Response(200, __('api_msg.unfollow_successfully'));
            } else {

                $insert['user_id'] = $user_id;
                $insert['artist_id'] = $artist_id;
                $insert['status'] = 1;
                Follow::insertGetId($insert);

                return $this->common->API_Response(200, __('api_msg.follow_successfully'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_content_to_history(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_type' => 'required|numeric',
                    'audiobook_type' => 'required|numeric',
                    'user_id' => 'required|numeric',
                    'content_id' => 'required|numeric',
                    'content_episode_id' => 'numeric',
                    'stop_time' => 'required|numeric',
                ],
                [
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'audiobook_type.required' => __('api_msg.audiobook_type_is_required'),
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                    'content_episode_id.required' => __('api_msg.content_episode_id_is_required'),
                    'stop_time.required' => __('api_msg.stop_time_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_type = $request['content_type'];
            $audiobook_type = $request['audiobook_type'];
            $user_id = $request['user_id'];
            $content_id = $request['content_id'];
            $content_episode_id = $request['content_episode_id'];
            $stop_time = $request['stop_time'];

            $content = History::where('user_id', $user_id)->where('content_type', $content_type)->where('audiobook_type', $audiobook_type)->where('content_id', $content_id)->latest()->first();
            if ($content != null && isset($content)) {

                $content['content_episode_id'] = $content_episode_id;
                $content['stop_time'] = $stop_time;
                $content->save();
            } else {

                $insert = new History();
                $insert['content_type'] = $content_type;
                $insert['audiobook_type'] = $audiobook_type;
                $insert['user_id'] = $user_id;
                $insert['content_id'] = $content_id;
                $insert['content_episode_id'] = $content_episode_id;
                $insert['stop_time'] = $stop_time;
                $insert['status'] = 1;
                $insert->save();
            }
            return $this->common->API_Response(200, __('api_msg.content_add_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function remove_content_to_history(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_type' => 'required|numeric',
                    'audiobook_type' => 'required|numeric',
                    'user_id' => 'required|numeric',
                    'content_id' => 'required|numeric',
                    'content_episode_id' => 'numeric',
                ],
                [
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'audiobook_type.required' => __('api_msg.audiobook_type_is_required'),
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                    'content_episode_id.required' => __('api_msg.content_episode_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_type = $request['content_type'];
            $audiobook_type = $request['audiobook_type'];
            $user_id = $request['user_id'];
            $content_id = $request['content_id'];
            $content_episode_id = $request['content_episode_id'];

            History::where('content_type', $content_type)->where('audiobook_type', $audiobook_type)->where('user_id', $user_id)->where('content_id', $content_id)->where('content_episode_id', $content_episode_id)->delete();
            return $this->common->API_Response(200, __('api_msg.content_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function search_content(Request $request) // Type = 1- AudioBook, 2- Novel, 3- Music, 4- Artist , 5- User
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'name' => 'required',
                    'type' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'name.required' => __('api_msg.name_is_required'),
                    'type.required' => __('api_msg.type_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $name = $request->name;
            $type = $request->type;
            $user_id = isset($request->user_id) ? $request->user_id : 0;
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($type == 1) {

                $data = Content::where('title', 'LIKE', "%{$name}%")->where('content_type', 1)->where('status', 1)->orderBy('id', 'DESC');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['landscape_img']);
                        $data[$i]['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['full_novel']);
                        $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                        $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                        $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                        $data[$i]['avg_rating'] = $this->common->getAvgRating($data[$i]['content_type'], $data[$i]['id']);
                        $data[$i]['total_episode'] = $this->common->getTotalEpisode($data[$i]['id']);
                        $data[$i]['total_user_play'] = $this->common->getTotalPlay($data[$i]['content_type'], $data[$i]['id']);
                    }
                    return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } elseif ($type == 2) {

                $data = Content::where('title', 'LIKE', "%{$name}%")->where('content_type', 2)->where('status', 1)->orderBy('id', 'DESC');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['landscape_img']);
                        $data[$i]['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['full_novel']);
                        $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                        $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                        $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                        $data[$i]['avg_rating'] = $this->common->getAvgRating($data[$i]['content_type'], $data[$i]['id']);
                        $data[$i]['total_episode'] = $this->common->getTotalEpisode($data[$i]['id']);
                        $data[$i]['total_user_play'] = $this->common->getTotalPlay($data[$i]['content_type'], $data[$i]['id']);
                    }
                    return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } elseif ($type == 3) {

                $data = Music::where('title', 'LIKE', "%{$name}%")->where('status', 1)->orderBy('id', 'DESC');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['portrait_img'] = $this->common->getImage($this->folder_music, $data[$i]['portrait_img']);
                        $data[$i]['landscape_img'] = $this->common->getImage($this->folder_music, $data[$i]['landscape_img']);
                        $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                        $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                        $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                        if ($data[$i]['music_upload_type'] == 'server_video') {
                            $data[$i]['music'] = $this->common->getBook($this->folder_music, $data[$i]['music']);
                        }
                    }
                    return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } elseif ($type == 4) {

                $data = Artist::where('user_name', 'LIKE', "%{$name}%")->where('status', 1)->orderBy('id', 'DESC');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {

                        $data[$i]['image'] = $this->common->getImage($this->folder_artist, $data[$i]['image']);
                        $data[$i]['followers'] = $this->common->getArtistFollowers($data[$i]['id']);
                    }
                    return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            } elseif ($type == 5) {

                $data =  User::where(function ($query) use ($name) {
                    $query->where('user_name', 'LIKE', "%{$name}%")
                        ->orWhere('full_name', 'LIKE', "%{$name}%");
                })
                    ->where('id', '!=', $user_id)->where('status', 1)->orderBy('id', 'DESC');

                $total_rows = $data->count();
                $total_page = $this->page_limit;
                $page_size = ceil($total_rows / $total_page);
                $current_page = $request->page_no ?? 1;
                $offset = $current_page * $total_page - $total_page;

                $more_page = $this->common->more_page($current_page, $page_size);
                $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

                $data->take($total_page)->offset($offset);
                $data = $data->get();

                if (count($data) > 0) {

                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = $this->common->getImage($this->folder_user, $data[$i]['image']);
                    }

                    return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
                } else {
                    return $this->common->API_Response(400, __('api_msg.data_not_found'));
                }
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_content_play(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'content_type' => 'required|numeric',
                    'audiobook_type' => 'required|numeric',
                    'user_id' => 'required|numeric',
                    'content_id' => 'required|numeric',
                    'content_episode_id' => 'required|numeric',
                ],
                [
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'audiobook_type.required' => __('api_msg.audiobook_type_is_required'),
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                    'content_episode_id.required' => __('api_msg.content_episode_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $content_type = $request['content_type'];
            $audiobook_type = $request['audiobook_type'];
            $user_id = $request['user_id'];
            $content_id = $request['content_id'];
            $content_episode_id = $request['content_episode_id'];

            $play = Content_Play::where('content_type', $content_type)->where('audiobook_type', $audiobook_type)
                ->where('user_id', $user_id)->where('content_id', $content_id)->where('content_episode_id', $content_episode_id)->latest()->first();
            if ($play == null && !isset($play)) {

                $insert['content_type'] = $content_type;
                $insert['audiobook_type'] = $audiobook_type;
                $insert['user_id'] = $user_id;
                $insert['content_id'] = $content_id;
                $insert['content_episode_id'] = $content_episode_id;
                $insert['status'] = 1;
                Content_Play::insertGetId($insert);
            }

            if ($content_type == 1) {

                if ($play == null && !isset($play)) {
                    if ($audiobook_type == 1) {
                        Content_Episode::where('id', $content_episode_id)->increment('total_audio_played', 1);
                    } else if ($audiobook_type == 2) {
                        Content_Episode::where('id', $content_episode_id)->increment('total_video_played', 1);
                    }
                }
            } else if ($content_type == 2) {

                if ($play == null && !isset($play)) {
                    if ($content_episode_id == 0) {
                        Content::where('id', $content_id)->increment('total_played', 1);
                    } else if ($content_episode_id != 0) {
                        Content_Episode::where('id', $content_episode_id)->increment('total_book_played', 1);
                    }
                }
            } else if ($content_type == 3) {

                if ($play == null && !isset($play)) {
                    Music::where('id', $content_id)->increment('total_played', 1);
                }
            }

            return $this->common->API_Response(200, __('api_msg.content_view_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_content_by_artist(Request $request) // Type = 1- AudioBook, 2- Novel
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'artist_id' => 'required|numeric',
                    'type' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'artist_id.required' => __('api_msg.artist_id_is_required'),
                    'type.required' => __('api_msg.type_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $type = $request['type'];
            $artist_id = $request['artist_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Content::where('artist_id', $artist_id)->where('content_type', $type)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['portrait_img']);
                    $data[$i]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['landscape_img']);
                    $data[$i]['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['full_novel']);
                    $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                    $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                    $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                    $data[$i]['avg_rating'] = $this->common->getAvgRating($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['total_episode'] = $this->common->getTotalEpisode($data[$i]['id']);
                    $data[$i]['total_reviews'] = $this->common->getTotalReviews($data[$i]['id']);
                    $data[$i]['total_user_play'] = $this->common->getTotalPlay($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content_type'], $data[$i]['id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_music_by_artist(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'artist_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'artist_id.required' => __('api_msg.artist_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $artist_id = $request['artist_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Music::where('artist_id', $artist_id)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['portrait_img'] = $this->common->getImage($this->folder_music, $data[$i]['portrait_img']);
                    $data[$i]['landscape_img'] = $this->common->getImage($this->folder_music, $data[$i]['landscape_img']);
                    if ($data[$i]['music_upload_type'] == 'server_video') {
                        $data[$i]['music'] = $this->common->getBook($this->folder_music, $data[$i]['music']);
                    }
                    $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                    $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                    $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_threads_by_artist(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'artist_id' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'artist_id.required' => __('api_msg.artist_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $artist_id = $request['artist_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Threads::where('user_type', 2)->where('user_id', $artist_id)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_threads);
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_notification(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $user_notification_id = Read_Notification::where('user_id', $user_id)->where('status', 1)->get();
            $NotiIds = [];
            foreach ($user_notification_id as $key => $value) {
                $NotiIds[] = $value['notification_id'];
            }
            $data = Notification::where('status', 1)->whereNotIn('id', $NotiIds)->orderBy('id', 'desc')->latest();

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            $this->common->imageNameToUrl($data, 'image', $this->folder_notification);

            return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function read_notification(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'notification_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'notification_id.required' => __('api_msg.notification_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $notification_id = $request['notification_id'];

            $get_data = Notification::where('id', $notification_id)->first();
            if ($get_data != null && isset($get_data)) {

                $check_read = Read_Notification::where('user_id', $user_id)->where('notification_id', $notification_id)->where('status', 1)->first();
                if ($check_read == null && !isset($check_read)) {

                    $insert = new Read_Notification();
                    $insert['user_id'] = $user_id;
                    $insert['notification_id'] = $notification_id;
                    $insert['status'] = 1;
                    $insert->save();
                }
            }
            return $this->common->API_Response(200, __('api_msg.read_notification_successfully'), []);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_transaction(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'package_id' => 'required|numeric',
                    'price' => 'required|numeric',
                    'coin' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'package_id.required' => __('api_msg.package_id_is_required'),
                    'price.required' => __('api_msg.price_is_required'),
                    'coin.required' => __('api_msg.coin_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request->user_id;
            $package_id = $request->package_id;
            $price = $request->price;
            $coin = $request->coin;
            $description = isset($request->description) ? $request->description : "";
            $transaction_id = isset($request->transaction_id) ? $request->transaction_id : "";

            $insert = new Transaction();
            $insert->user_id = $user_id;
            $insert->package_id = $package_id;
            $insert->description = $description;
            $insert->price = $price;
            $insert->coin = $coin;
            $insert->transaction_id = $transaction_id;
            $insert->status = 1;

            if ($insert->save()) {

                User::where('id', $user_id)->increment('wallet_coin', $coin);

                // Send Mail (Type = 1- Register Mail, 2 Transaction Mail)
                $user_email = User::where('id', $user_id)->first();
                if ($user_email != null && isset($user_email)) {
                    $this->common->Send_Mail(2, $user_email);
                }

                return $this->common->API_Response(200, __('api_msg.transaction_successfully'), []);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function buy_content_episode(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'content_type' => 'required|numeric',
                    'audiobook_type' => 'required|numeric',
                    'content_id' => 'required|numeric',
                    'content_episode_id' => 'required|numeric',
                    'coin' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'audiobook_type.required' => __('api_msg.audiobook_type_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
                    'content_episode_id.required' => __('api_msg.content_episode_id_is_required'),
                    'coin.required' => __('api_msg.coin_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_wallet_coin = User::where('id', $request->user_id)->first();
            if ($user_wallet_coin != null && isset($user_wallet_coin)) {

                if ($request->coin >= $user_wallet_coin['wallet_coin']) {
                    return $this->common->API_Response(400, __('api_msg.recharge_your_wallet'));
                }
            } else {
                return $this->common->API_Response(400, __('api_msg.user_not_found'));
            }

            $insert = new Wallet_Transaction();
            $insert->user_id = $request->user_id;
            $insert->content_type = $request->content_type;
            $insert->audiobook_type = $request->audiobook_type;
            $insert->content_id = $request->content_id;
            $insert->content_episode_id = $request->content_episode_id;
            $insert->coin = $request->coin;
            $insert->status = 1;
            if ($insert->save()) {

                User::where('id', $request->user_id)->decrement('wallet_coin', $request->coin);

                return $this->common->API_Response(200, __('api_msg.transaction_successfully'), []);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    /**
     * Check if user has active subscription
     * @param Request $request
     * @return array
     */
    public function check_subscription_active(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user = User::where('id', $request->user_id)->first();

            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.user_not_found'));
            }

            $is_active = 0;
            $days_remaining = 0;
            $expiry_date = null;

            // Check if subscription is still active
            if ($user->subscription_active == 1 && $user->subscription_expiry_date) {
                $expiry_time = strtotime($user->subscription_expiry_date);
                $current_time = time();

                if ($current_time < $expiry_time) {
                    $is_active = 1;
                    $days_remaining = floor(($expiry_time - $current_time) / (60 * 60 * 24));
                    $expiry_date = $user->subscription_expiry_date;
                } else {
                    // Subscription expired - update user status
                    User::where('id', $request->user_id)->update([
                        'subscription_active' => 0,
                    ]);
                }
            }

            $response_data = [
                'is_active' => $is_active,
                'expiry_date' => $expiry_date,
                'plan_type' => $user->subscription_plan_type ?? 'week',
                'days_remaining' => $days_remaining,
            ];

            return $this->common->API_Response(200, 'Subscription status retrieved', $response_data);

        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    /**
     * Add subscription transaction
     * @param Request $request
     * @return array
     */
    public function add_subscription_transaction(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'payment_id' => 'required|string',
                    'amount' => 'required|numeric',
                    'plan_period' => 'required|in:week,month',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'payment_id.required' => 'Payment ID is required',
                    'amount.required' => 'Amount is required',
                    'plan_period.required' => 'Plan period is required',
                ]
            );

            if ($validation->fails()) {
                return $this->common->API_Response(400, $validation->errors()->first());
            }

            $user_id = $request->user_id;
            $payment_id = $request->payment_id;
            $amount = $request->amount;
            $plan_period = $request->plan_period;
            $coupon_code = isset($request->coupon_code) ? $request->coupon_code : null;

            // Calculate expiry date
            $expiry_date = now();
            if ($plan_period == 'month') {
                $expiry_date = $expiry_date->addMonth();
            } else {
                // week
                $expiry_date = $expiry_date->addWeek();
            }

            // Update user subscription status
            User::where('id', $user_id)->update([
                'subscription_active' => 1,
                'subscription_expiry_date' => $expiry_date,
                'subscription_plan_type' => $plan_period,
                'subscription_payment_id' => $payment_id,
            ]);

            // Create transaction record
            $transaction = new Transaction();
            $transaction->user_id = $user_id;
            $transaction->package_id = 0; // 0 for subscription
            $transaction->description = "Subscription Payment - $plan_period";
            $transaction->price = $amount;
            $transaction->coin = 0; // No coins for subscription
            $transaction->transaction_id = $payment_id;
            $transaction->status = 1;
            $transaction->save();

            // Send confirmation email
            $user_email = User::where('id', $user_id)->first();
            if ($user_email && isset($user_email)) {
                $this->common->Send_Mail(2, $user_email);
            }

            $response_data = [
                'expiry_date' => $expiry_date->format('Y-m-d H:i:s'),
                'plan_type' => $plan_period,
                'message' => 'Subscription activated successfully',
            ];

            return $this->common->API_Response(200, 'Subscription activated successfully', $response_data);

        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    public function get_artist_suggestion_list(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $follow_artist = Follow::where('user_id', $user_id)->latest()->get();
            $artist_id = [];
            for ($i = 0; $i < count($follow_artist); $i++) {
                $artist_id[] = $follow_artist[$i]['artist_id'];
            }

            $data = Artist::whereNotIn('id', $artist_id)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['image'] = $this->common->getImage($this->folder_artist, $data[$i]['image']);
                    $data[$i]['is_follow'] = $this->common->isFollow($user_id, $data[$i]['id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_threads_by_user(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Threads::where('user_type', 1)->where('user_id', $user_id)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                $this->common->imageNameToUrl($data, 'image', $this->folder_threads);
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_content_by_category(Request $request) // Type = 1- AudioBook, 2- Novel
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'category_id' => 'required|numeric',
                    'type' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'category_id.required' => __('api_msg.category_id_is_required'),
                    'type.required' => __('api_msg.type_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $type = $request['type'];
            $category_id = $request['category_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Content::where('category_id', $category_id)->where('content_type', $type)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['portrait_img']);
                    $data[$i]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['landscape_img']);
                    $data[$i]['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$i]['web_banner_img']);
                    $data[$i]['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['full_novel']);
                    $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                    $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                    $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                    $data[$i]['avg_rating'] = $this->common->getAvgRating($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['total_episode'] = $this->common->getTotalEpisode($data[$i]['id']);
                    $data[$i]['total_reviews'] = $this->common->getTotalReviews($data[$i]['id']);
                    $data[$i]['total_user_play'] = $this->common->getTotalPlay($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content_type'], $data[$i]['id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_content_by_language(Request $request) // Type = 1- AudioBook, 2- Novel
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'language_id' => 'required|numeric',
                    'type' => 'required|numeric',
                    'user_id' => 'numeric',
                ],
                [
                    'language_id.required' => __('api_msg.language_id_is_required'),
                    'type.required' => __('api_msg.type_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $type = $request['type'];
            $language_id = $request['language_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Content::where('language_id', $language_id)->where('content_type', $type)->where('status', 1)->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['portrait_img']);
                    $data[$i]['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['landscape_img']);
                    $data[$i]['web_banner_img'] = $this->common->getWebImage($this->folder_content, $data[$i]['web_banner_img']);
                    $data[$i]['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['full_novel']);
                    $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                    $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                    $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                    $data[$i]['avg_rating'] = $this->common->getAvgRating($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['total_episode'] = $this->common->getTotalEpisode($data[$i]['id']);
                    $data[$i]['total_reviews'] = $this->common->getTotalReviews($data[$i]['id']);
                    $data[$i]['total_user_play'] = $this->common->getTotalPlay($data[$i]['content_type'], $data[$i]['id']);
                    $data[$i]['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content_type'], $data[$i]['id']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_transaction_list(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Transaction::where('user_id', $user_id)->with('user', 'package')->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['image'] = asset('assets/imgs/default.png');
                    if ($data[$i]['user'] != null && isset($data[$i]['user'])) {

                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
                    }

                    $data[$i]['package_name'] = "";
                    if ($data[$i]['package'] != null && isset($data[$i]['package'])) {
                        $data[$i]['package_name'] = $data[$i]['package']['name'];
                    }

                    unset($data[$i]['user'], $data[$i]['package']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_wallet_transaction_list(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Wallet_Transaction::where('user_id', $user_id)->with('user', 'content', 'episode')->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['user_image'] = asset('assets/imgs/default.png');
                    if ($data[$i]['user'] != null && isset($data[$i]['user'])) {

                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['user_image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
                    }

                    $data[$i]['content_title'] = "";
                    $data[$i]['content_portrait_img'] = asset('assets/imgs/no_img.png');
                    if ($data[$i]['content'] != null) {
                        $data[$i]['content_title'] = $data[$i]['content']['title'];
                        $data[$i]['content_portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['portrait_img']);
                    }

                    $data[$i]['episode_name'] = "";
                    $data[$i]['episode_image'] = asset('assets/imgs/no_img.png');
                    if ($data[$i]['episode'] != null) {
                        $data[$i]['episode_name'] = $data[$i]['episode']['name'];
                        $data[$i]['episode_image'] = $this->common->getImage($this->folder_content, $data[$i]['episode']['image']);
                    }
                    unset($data[$i]['user'], $data[$i]['content'], $data[$i]['episode']);
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_earn_coin()
    {
        try {
            $spin_wheel = Reward_Coin::select('id', 'key', 'value', 'type')->where('type', '1')->get();
            $daily_login = Reward_Coin::select('id', 'key', 'value', 'type')->where('type', '2')->get();
            $free_coin = Reward_Coin::select('id', 'key', 'value', 'type')->where('type', '3')->get();

            if ($spin_wheel && $daily_login && $free_coin) {
                $subarray['status'] = 200;
                $subarray['message'] = __('api_msg.get_record_successfully');

                $subarray['spin_wheel'] = $spin_wheel;
                $subarray['daily_login'] = $daily_login;
                $subarray['free_coin'] = $free_coin;

                return $subarray;
            } else {
                return $this->common->API_Response(400,  __('api_msg.record_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_earn_coin_transaction(Request $request) // 1- Spin_Wheel, 2- Daily_Login_Point, 3- Get_Free_Coin	
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'coin' => 'required|numeric',
                    'type' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'coin.required' => __('api_msg.coin_is_required'),
                    'type.required' => __('api_msg.type_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $coin = $request['coin'];
            $type = $request['type'];

            $insert = new Reward_Transaction();
            $insert['user_id'] = $user_id;
            $insert['coin'] = $coin;
            $insert['type'] = $type;
            if ($insert->save()) {

                User::where('id', $request->user_id)->increment('wallet_coin', $coin);
                return $this->common->API_Response(200, __('api_msg.transaction_successfully'), []);
            } else {
                return $this->common->API_Response(400,  __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_earn_coin_transaction_list(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Reward_Transaction::where('user_id', $user_id)->with('user')->orderBy('id', 'DESC');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['user_image'] = asset('assets/imgs/default.png');
                    if ($data[$i]['user'] != null && isset($data[$i]['user'])) {

                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['user_image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
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
    public function add_remove_bookmark(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'content_type' => 'required|numeric',
                    'content_id' => 'required|numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'content_type.required' => __('api_msg.content_type_is_required'),
                    'content_id.required' => __('api_msg.content_id_is_required'),
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

            $content = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->latest()->first();
            if ($content != null && isset($content)) {

                $content->delete();
                return $this->common->API_Response(200, __('api_msg.remove_successfully'));
            } else {

                $insert = new Bookmark();
                $insert['user_id'] = $user_id;
                $insert['content_type'] = $content_type;
                $insert['content_id'] = $content_id;
                $insert['status'] = 1;
                $insert->save();
            }
            return $this->common->API_Response(200, __('api_msg.add_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_bookmark_list(Request $request)
    {
        try {

            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'content_type' => 'numeric',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $content_type = isset($request->content_type) ? $request->content_type : 0;
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            if ($content_type == 0) {
                $data = Bookmark::where('user_id', $user_id)->with('content')->orderBy('id', 'DESC');
            } else {
                $data = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->with('content')->orderBy('id', 'DESC');
            }

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            if (count($data) > 0) {

                $return = [];
                for ($i = 0; $i < count($data); $i++) {

                    if ($data[$i]['content'] != null) {

                        $data[$i]['content']['portrait_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['portrait_img']);
                        $data[$i]['content']['landscape_img'] = $this->common->getImage($this->folder_content, $data[$i]['content']['landscape_img']);
                        $data[$i]['content']['full_novel'] = $this->common->getBook($this->folder_content, $data[$i]['content']['full_novel']);
                        $data[$i]['content']['category_name'] = $this->common->getCategoryName($data[$i]['content']['category_id']);
                        $data[$i]['content']['artist_name'] = $this->common->getArtistName($data[$i]['content']['artist_id']);
                        $data[$i]['content']['language_name'] = $this->common->getLanguageName($data[$i]['content']['language_id']);
                        $data[$i]['content']['avg_rating'] = $this->common->getAvgRating($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['total_episode'] = $this->common->getTotalEpisode($data[$i]['content']['id']);
                        $data[$i]['content']['total_reviews'] = $this->common->getTotalReviews($data[$i]['content']['id']);
                        $data[$i]['content']['total_user_play'] = $this->common->getTotalPlay($data[$i]['content']['content_type'], $data[$i]['content']['id']);
                        $data[$i]['content']['is_bookmark'] = $this->common->isBookmark($user_id, $data[$i]['content']['content_type'], $data[$i]['content']['id']);

                        $return[] = $data[$i]['content'];
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $return, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
