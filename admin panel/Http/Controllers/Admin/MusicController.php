<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
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

            $params['data'] = [];
            $params['category'] = Category::orderby('name', 'asc')->latest()->get();
            $params['language'] = Language::orderby('name', 'asc')->latest()->get();
            $params['artist'] = Artist::orderby('user_name', 'asc')->latest()->get();

            $input_search = $request['input_search'];
            $input_category = $request['input_category'];
            $input_language = $request['input_language'];
            $input_artist = $request['input_artist'];

            if ($input_search != null && isset($input_search)) {

                if ($input_category != 0 && $input_language == 0 && $input_artist == 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0 && $input_artist == 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language == 0 && $input_artist != 1) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0 && $input_artist == 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language == 0 && $input_artist != 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0 && $input_artist != 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('language_id', $input_language)->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0 && $input_artist != 0) {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->where('category_id', $input_category)->where('language_id', $input_language)->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } else {

                    $params['data'] = Music::where('title', 'LIKE', "%{$input_search}%")->orderBy('id', 'DESC')->paginate(15);
                }
            } else {

                if ($input_category != 0 && $input_language == 0 && $input_artist == 0) {
                    $params['data'] = Music::where('category_id', $input_category)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0 && $input_artist == 0) {
                    $params['data'] = Music::where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language == 0 && $input_artist != 0) {
                    $params['data'] = Music::where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0 && $input_artist == 0) {
                    $params['data'] = Music::where('category_id', $input_category)->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language == 0 && $input_artist != 0) {
                    $params['data'] = Music::where('category_id', $input_category)->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category == 0 && $input_language != 0 && $input_artist != 0) {
                    $params['data'] = Music::where('language_id', $input_language)->where('artist_id', $input_artist)->orderBy('id', 'DESC')->paginate(15);
                } elseif ($input_category != 0 && $input_language != 0 && $input_artist != 0) {
                    $params['data'] = Music::where('category_id', $input_category)->where('artist_id', $input_artist)->where('language_id', $input_language)->orderBy('id', 'DESC')->paginate(15);
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

            return view('admin.music.index', $params);
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
            $params['artist'] = Artist::orderBy('user_name', 'asc')->latest()->get();

            return view('admin.music.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'artist_id' => 'required',
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
                $params['artist'] = Artist::orderby('user_name', 'asc')->latest()->get();

                $this->common->imageNameToUrl(array($params['data']), 'portrait_img', $this->folder);
                $this->common->imageNameToUrl(array($params['data']), 'landscape_img', $this->folder);
                if ($params['data']['music_upload_type'] == 'server_video') {
                    $this->common->videoNameToUrl(array($params['data']), 'music', $this->folder);
                }

                return view('admin.music.edit', $params);
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
                'artist_id' => 'required',
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

            return redirect()->route('music.index')->with('success', __('Label.data_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    // Status Change
    public function changeStatus(Request $request)
    {
        try {

            $data = Music::where('id', $request->id)->first();
            if ($data->status == 0) {
                $data->status = 1;
            } elseif ($data->status == 1) {
                $data->status = 0;
            } else {
                $data->status = 0;
            }
            $data->save();
            return response()->json(array('status' => 200, 'success' => 'Status Changed', 'id' => $data->id, 'Status' => $data->status));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    // Save Chunk
    public function saveChunk()
    {
        @set_time_limit(5 * 60);

        $targetDir = storage_path('/app/public/music');
        //$targetDir = 'uploads';

        $cleanupTargetDir = true; // Remove old files

        $maxFileAge = 5 * 3600; // Temp file age in seconds

        // Create target dir
        if (!file_exists($targetDir)) {
            @mkdir($targetDir);
        }

        // Get a file name
        if (isset($_REQUEST["name"])) {
            $fileName = $_REQUEST["name"];
        } elseif (!empty($_FILES)) {
            $fileName = $_FILES["file"]["name"];
        } else {
            $fileName = uniqid("file_");
        }
        $category_image = $fileName;
        $filePath = $targetDir . DIRECTORY_SEPARATOR . $category_image;
        // Chunking might be enabled

        $chunk = isset($_REQUEST["chunk"]) ? intval($_REQUEST["chunk"]) : 0;
        $chunks = isset($_REQUEST["chunks"]) ? intval($_REQUEST["chunks"]) : 0;
        // Remove old temp files

        if ($cleanupTargetDir) {
            if (!is_dir($targetDir) || !$dir = opendir($targetDir)) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 100, "message": "Failed to open temp directory."}, "id" : "id"}');
            }

            while (($file = readdir($dir)) !== false) {
                $tmpfilePath = $targetDir . DIRECTORY_SEPARATOR . $file;
                // If temp file is current file proceed to the next
                if ($tmpfilePath == "{$filePath}.part") {
                    continue;
                }

                // Remove temp file if it is older than the max age and is not the current file
                if (preg_match('/\.part$/', $file) && (filemtime($tmpfilePath) < time() - $maxFileAge)) {
                    @unlink($tmpfilePath);
                }
            }
            closedir($dir);
        }

        // Open temp file

        if (!$out = @fopen("{$filePath}.part", $chunks ? "ab" : "wb")) {
            die('{"jsonrpc" : "2.0", "error" : {"code": 102, "message": "Failed to open output stream."}, "id" : "id"}');
        }

        if (!empty($_FILES)) {
            if ($_FILES["file"]["error"] || !is_uploaded_file($_FILES["file"]["tmp_name"])) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 103, "message": "Failed to move uploaded file."}, "id" : "id"}');
            }

            // Read binary input stream and append it to temp file
            if (!$in = @fopen($_FILES["file"]["tmp_name"], "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        } else {
            if (!$in = @fopen("php://input", "rb")) {
                die('{"jsonrpc" : "2.0", "error" : {"code": 101, "message": "Failed to open input stream."}, "id" : "id"}');
            }
        }

        while ($buff = fread($in, 4096)) {
            fwrite($out, $buff);
        }

        @fclose($out);
        @fclose($in);
        // Check if file has been uploaded
        if (!$chunks || $chunk == $chunks - 1) {
            // Strip the temp .part suffix off
            rename("{$filePath}.part", $filePath);
        }
        // Return Success JSON-RPC response
        die('{"jsonrpc" : "2.0", "result" : null, "id" : "id"}');
    }
}
