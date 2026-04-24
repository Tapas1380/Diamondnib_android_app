<?php

namespace App\Http\Controllers\Artist;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content_Play;
use App\Models\History;
use App\Models\Language;
use App\Models\Music;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class MusicController extends Controller
{
    private $folder = "music";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $artist = Artist_Data();
            $params['data'] = [];
            $params['category'] = Category::orderby('name', 'asc')->latest()->get();
            $params['language'] = Language::orderby('name', 'asc')->latest()->get();

            $input_search = $request['input_search'];
            $input_category = $request['input_category'];
            $input_language = $request['input_language'];

            if ($input_search != null && isset($input_search)) {

                if ($input_category != 0 && $input_language == 0) {
                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0) {
                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0) {
                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } else {
                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->orderBy('id', 'DESC')->paginate(15);
                }
            } else {

                if ($input_category != 0 && $input_language == 0) {
                    $params['data'] = Music::where('category_id', $input_category)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0) {
                    $params['data'] = Music::where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0) {
                    $params['data'] = Music::where('category_id', $input_category)->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } else {
                    $params['data'] = Music::orderBy('id', 'DESC')->paginate(15);
                }
            }

            $this->common->imageNameToUrl($params['data'], 'portrait_img', $this->folder);
            $this->common->imageNameToUrl($params['data'], 'landscape_img', $this->folder);

            for ($i = 0; $i < count($params['data']); $i++) {
                if ($params['data'][$i]['music_upload_type'] == 'server_video') {
                    $this->common->videoNameToUrl(array($params['data'][$i]), 'music', $this->folder);
                }
            }

            return view('artist.music.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];

            $params['category'] = Category::orderBy('name', 'asc')->latest()->get();
            $params['language'] = Language::orderBy('name', 'asc')->latest()->get();

            return view('artist.music.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $artist = Artist_Data();

            $validator = Validator::make($request->all(), [
                'category_id' => 'required',
                'language_id' => 'required',
                'title' => 'required',
                'description' => 'required',
                'portrait_img' => 'required|image|mimes:jpeg,png,jpg|max:2048',
                'landscape_img' => 'required|image|mimes:jpeg,png,jpg|max:2048',
                'music_upload_type' => 'required',
                'music_duration' => 'required|after_or_equal:00:00:00',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }
            if ($request->music_upload_type == 'server_video') {
                $validator2 = Validator::make($request->all(), [
                    'music' => 'required',
                ]);
            } else {
                $validator2 = Validator::make($request->all(), [
                    'music_url' => 'required',
                ]);
            }
            if ($validator2->fails()) {
                $errs2 = $validator2->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs2));
            }

            $requestData = $request->all();
            $requestData['artist_id'] = $artist['id'];

            $files1 = $requestData['portrait_img'];
            $files2 = $requestData['landscape_img'];
            $requestData['portrait_img'] = $this->common->saveImage($files1, $this->folder);
            $requestData['landscape_img'] = $this->common->saveImage($files2, $this->folder);
            $requestData['music_duration'] = TimeToMilliseconds($requestData['music_duration']);
            if ($requestData['music_upload_type'] == 'server_video') {
                $requestData['music'] = $requestData['music'];
            } else {
                $requestData['music'] = $requestData['music_url'];
            }
            $requestData['total_played'] = 0;
            $requestData['status'] = 1;

            unset($requestData['music_url']);

            $music_data = Music::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($music_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = Music::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['category'] = Category::orderby('name', 'asc')->latest()->get();
                $params['language'] = Language::orderby('name', 'asc')->latest()->get();

                $this->common->imageNameToUrl(array($params['data']), 'portrait_img', $this->folder);
                $this->common->imageNameToUrl(array($params['data']), 'landscape_img', $this->folder);
                if ($params['data']['music_upload_type'] == 'server_video') {
                    $this->common->videoNameToUrl(array($params['data']), 'music', $this->folder);
                }

                return view('artist.music.edit', $params);
            } else {
                return redirect()->back()->with('error', __('Label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required',
                'description' => 'required',
                'category_id' => 'required',
                'language_id' => 'required',
                'portrait_img' => 'image|mimes:jpeg,png,jpg|max:2048',
                'landscape_img' => 'image|mimes:jpeg,png,jpg|max:2048',
                'music_upload_type' => 'required',
                'music_duration' => 'required|after_or_equal:00:00:00',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }
            if ($request->music_upload_type != 'server_video') {
                $validator2 = Validator::make($request->all(), [
                    'music_url' => 'required',
                ]);
                if ($validator2->fails()) {
                    $errs2 = $validator2->errors()->all();
                    return response()->json(array('status' => 400, 'errors' => $errs2));
                }
            }

            $requestData = $request->all();

            if (isset($requestData['portrait_img'])) {
                $files = $requestData['portrait_img'];
                $requestData['portrait_img'] = $this->common->saveImage($files, $this->folder);
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_portrait_img']));
            }
            if (isset($requestData['landscape_img'])) {
                $files1 = $requestData['landscape_img'];
                $requestData['landscape_img'] = $this->common->saveImage($files1, $this->folder);
                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_landscape_img']));
            }
            $requestData['music_duration'] = TimeToMilliseconds($requestData['music_duration']);
            if ($requestData['music_upload_type'] == 'server_video') {

                if ($requestData['music_upload_type'] == $requestData['old_music_upload_type']) {

                    if ($requestData['music']) {
                        $requestData['music'] = $requestData['music'];
                        $this->common->deleteImageToFolder($this->folder, basename($requestData['old_music']));
                    } else {
                        $requestData['music'] = basename($requestData['old_music']);
                    }
                } else {

                    if ($requestData['music']) {
                        $requestData['music'] = $requestData['music'];
                        $this->common->deleteImageToFolder($this->folder, basename($requestData['old_music']));
                    } else {
                        $requestData['music'] = '';
                    }
                }
            } else {

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_music']));
                $requestData['music'] = "";
                if ($requestData['music_url']) {
                    $requestData['music'] = $requestData['music_url'];
                }
            }
            unset($requestData['music_url'], $requestData['old_music_upload_type'], $requestData['old_music'], $requestData['old_portrait_img'], $requestData['old_landscape_img']);

            $music_data = Music::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($music_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function show($id)
    {
        try {

            $data = Music::where('id', $id)->first();
            if (isset($data)) {

                $this->common->deleteImageToFolder($this->folder, $data['portrait_img']);
                $this->common->deleteImageToFolder($this->folder, $data['landscape_img']);
                $this->common->deleteImageToFolder($this->folder, $data['music']);
                $data->delete();

                Content_Play::where('content_type', 3)->where('content_id', $id)->delete();
                History::where('content_type', 3)->where('content_id', $id)->delete();
            }

            return redirect()->route('amusic.index')->with('success', __('Label.data_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
