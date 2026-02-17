<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\Music_Section;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

// is_home_screen = 1- Home Screen, 2- Other Screen
class MusicController extends Controller
{
    private $folder_music = "music";
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

    public function get_music_section(Request $request)
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

            $is_home_screen = $request['is_home_screen'];
            $top_category_id = isset($request->top_category_id) ? $request->top_category_id : 0;
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            if ($is_home_screen == 1) {
                $data = Music_Section::where('is_home_screen', $is_home_screen)->where('status', 1)->orderBy('sortable', 'asc')->latest();
            } else if ($is_home_screen == 2) {
                $data = Music_Section::where('is_home_screen', $is_home_screen)->where('top_category_id', $top_category_id)->where('status', 1)->orderBy('sortable', 'asc')->latest();
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
                    $query = $this->common->music_section_query($user_id, $data[$i]['category_id'], $data[$i]['language_id'], $data[$i]['artist_id'], $data[$i]['order_by_play'], $data[$i]['order_by_upload'], $data[$i]['no_of_content']);
                    $data[$i]['data'] = $query;
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_music_section_detail(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'section_id' => 'required|numeric',
                    'user_id' => 'numeric',
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

            $section_id = $request['section_id'];
            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_no = $request->page_no ?? 1;
            $page_size = 0;
            $more_page = false;

            $section = Music_Section::where('id', $section_id)->first();
            if ($section != null && isset($section)) {

                $data = $this->common->music_section_details_query($user_id, $section['category_id'], $section['language_id'], $section['artist_id'], $section['order_by_play'], $section['order_by_upload']);
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

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['portrait_img'] = $this->common->getImage($this->folder_music, $data[$i]['portrait_img']);
                    $data[$i]['landscape_img'] = $this->common->getImage($this->folder_music, $data[$i]['landscape_img']);
                    if ($data[$i]['music_upload_type'] == 'server_video') {
                        $data[$i]['music'] = $this->common->getBook($this->folder_music, $data[$i]['music']);
                    }
                    $data[$i]['category_name'] = $this->common->getCategoryName($data[$i]['category_id']);
                    $data[$i]['artist_name'] = $this->common->getArtistName($data[$i]['artist_id']);
                    $data[$i]['language_name'] = $this->common->getLanguageName($data[$i]['language_id']);
                    $data[$i]['content_type'] = 3;
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
