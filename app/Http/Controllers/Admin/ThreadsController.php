<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Comment;
use App\Models\Common;
use App\Models\Threads;
use App\Models\User;
use Illuminate\Http\Request;
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

            $params['data'] = [];
            $params['user'] = User::latest()->get();
            $params['artist'] = Artist::latest()->get();

            $input_search = $request['input_search'];
            $input_user = $request['input_user'];
            $input_artist = $request['input_artist'];

            if ($input_search != null && isset($input_search)) {

                if ($input_user != 0 && $input_artist == 0) {
                    $params['data'] = Threads::where('description', 'LIKE', "%{$input_search}%")->where('user_id', $input_user)->with('user', 'artist')->latest()->paginate(16);
                } else if ($input_user == 0 && $input_artist != 0) {
                    $params['data'] = Threads::where('description', 'LIKE', "%{$input_search}%")->where('user_is', $input_artist)->with('user', 'artist')->latest()->paginate(16);
                } else if ($input_user != 0 && $input_artist != 0) {
                    $params['data'] = Threads::where('description', 'LIKE', "%{$input_search}%")->whereIn('user_id', [$input_user, $input_artist])->with('user', 'artist')->latest()->paginate(16);
                } else {
                    $params['data'] = Threads::where('description', 'LIKE', "%{$input_search}%")->with('user', 'artist')->latest()->paginate(16);
                }
            } else {

                if ($input_user != 0 && $input_artist == 0) {
                    $params['data'] = Threads::where('user_id', $input_user)->with('user', 'artist')->latest()->paginate(16);
                } else if ($input_user == 0 && $input_artist != 0) {
                    $params['data'] = Threads::where('user_id', $input_artist)->with('user', 'artist')->latest()->paginate(16);
                } else if ($input_user != 0 && $input_artist != 0) {
                    $params['data'] = Threads::whereIn('user_id', [$input_user, $input_artist])->with('user', 'artist')->latest()->paginate(16);
                } else {
                    $params['data'] = Threads::with('user', 'artist')->latest()->paginate(16);
                }
            }

            $this->common->imageNameToUrl($params['data'], 'image', $this->folder);

            return view('admin.threads.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function show($id)
    {
        try {

            $data = Threads::where('id', $id)->first();
            if ($data->status == 0) {
                $data->status = 1;
            } elseif ($data->status == 1) {
                $data->status = 0;
            } else {
                $data->status = 0;
            }
            $data->save();
            return response()->json(array('status' => 200, 'success' => 'Status Changed', 'id' => $data->id, 'Status_Code' => $data->status));
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
                    ->addColumn('action', function ($row) {
                        if ($row->status == 1) {
                            return "<button type='button' id='$row->id' onclick='change_status($row->id, $row->status)' style='background:#058f00; font-weight:bold; border: none; color: white; padding: 5px 15px; outline: none;border-radius: 5px;cursor: pointer;'>Show</button>";
                        } else {
                            return "<button type='button' id='$row->id' onclick='change_status($row->id, $row->status)' style='background:#e3000b; font-weight:bold; border: none; color: white; padding: 5px 20px; outline: none;border-radius: 5px;cursor: pointer;'>Hide</button>";
                        }
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->make(true);
            }
            return view('admin.threads.com_index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function CommentStatus($id)
    {
        try {

            $data = Comment::where('id', $id)->first();
            if ($data->status == 0) {
                $data->status = 1;
            } elseif ($data->status == 1) {
                $data->status = 0;
            } else {
                $data->status = 0;
            }
            $data->save();
            return response()->json(array('status' => 200, 'success' => 'Status Changed', 'id' => $data->id, 'Status_Code' => $data->status));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
