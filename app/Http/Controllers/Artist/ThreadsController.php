<?php

namespace App\Http\Controllers\Artist;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Common;
use App\Models\Like;
use App\Models\Threads;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class ThreadsController extends Controller
{
    private $folder = "threads";
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

            $input_search = $request['input_search'];
            if ($input_search != null && isset($input_search)) {
                $params['data'] = Threads::where('user_type', 2)->where('user_id', $artist['id'])->where('description', 'LIKE', "%{$input_search}%")->latest()->paginate(16);
            } else {
                $params['data'] = Threads::where('user_type', 2)->where('user_id', $artist['id'])->latest()->paginate(16);
            }

            $this->common->imageNameToUrl($params['data'], 'image', $this->folder);

            return view('artist.threads.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $artist = Artist_Data();

            $validator = Validator::make($request->all(), [
                'description' => 'required',
                'image' => 'image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();
            $requestData['user_type'] = 2;
            $requestData['user_id'] = $artist['id'];
            $requestData['image'] = "";
            if ($request->image && $request->image != null && isset($request->image)) {
                $files = $request->image;
                $requestData['image'] = $this->common->saveImage($files, $this->folder);
            }
            $requestData['total_like'] = 0;
            $requestData['status'] = 1;

            $threads_data = Threads::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($threads_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function show($id)
    {
        try {

            $data = Threads::where('id', $id)->first();
            if (isset($data)) {

                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();

                Like::where('threads_id', $id)->delete();
                Comment::where('threads_id', $id)->delete();
            }

            return redirect()->route('athreads.index')->with('success', __('Label.data_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function CommentIndex($id, Request $request)
    {
        try {

            $params['data'] = [];
            $params['threads_id'] = $id;
            $params['user'] = User::latest()->get();

            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_user = $request['input_user'];

                if ($input_search != null && isset($input_search)) {

                    if ($input_user != 0) {
                        $data = Comment::where('comment', 'LIKE', "%{$input_search}%")->where('threads_id', $id)->where('user_id', $input_user)->with('user')->latest()->get();
                    } else {
                        $data = Comment::where('comment', 'LIKE', "%{$input_search}%")->where('threads_id', $id)->with('user')->latest()->get();
                    }
                } else {

                    if ($input_user != 0) {
                        $data = Comment::where('user_id', $input_user)->where('threads_id', $id)->with('user')->latest()->get();
                    } else {
                        $data = Comment::where('threads_id', $id)->with('user')->latest()->get();
                    }
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->make(true);
            }
            return view('artist.threads.com_index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
