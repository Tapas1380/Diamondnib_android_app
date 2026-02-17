<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Common;
use App\Models\Content_Play;
use App\Models\Follow;
use App\Models\History;
use App\Models\Like;
use App\Models\Read_Notification;
use App\Models\Reviews;
use App\Models\Reward_Transaction;
use App\Models\Threads;
use App\Models\User;
use App\Models\Wallet_Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

// Login Type : 1= OTP, 2= Goggle, 3= Apple, 4= Normal
class UserController extends Controller
{
    private $folder = "user";
    private $threads = "threads";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_type = $request['input_type'];
                $input_login_type = $request['input_login_type'];

                if ($input_search != null && isset($input_search)) {

                    if ($input_login_type == "all") {

                        if ($input_type == "today") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "month") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "year") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->whereYear('created_at', date('Y'))->latest()->get();
                        } else {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })->latest()->get();
                        }
                    } else {

                        if ($input_type == "today") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->where('type', $input_login_type)->whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))
                                ->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "month") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->where('type', $input_login_type)->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "year") {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })
                                ->where('type', $input_login_type)->whereYear('created_at', date('Y'))->latest()->get();
                        } else {

                            $data = User::where(function ($query) use ($input_search) {
                                $query->where('full_name', 'LIKE', "%{$input_search}%")->orWhere('email', 'LIKE', "%{$input_search}%")->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                            })->where('type', $input_login_type)->latest()->get();
                        }
                    }
                } else {

                    if ($input_login_type == "all") {

                        if ($input_type == "today") {
                            $data = User::whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "month") {
                            $data = User::whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "year") {
                            $data = User::whereYear('created_at', date('Y'))->latest()->get();
                        } else {
                            $data = User::latest()->get();
                        }
                    } else {

                        if ($input_type == "today") {
                            $data = User::where('type', $input_login_type)->whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "month") {
                            $data = User::where('type', $input_login_type)->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->latest()->get();
                        } else if ($input_type == "year") {
                            $data = User::where('type', $input_login_type)->whereYear('created_at', date('Y'))->latest()->get();
                        } else {
                            $data = User::where('type', $input_login_type)->latest()->get();
                        }
                    }
                }

                $this->common->imageNameToUrl($data, 'image', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $delete = '<form onsubmit="return confirm(\'Are you sure !!! You want to Delete this User ?\');" method="POST"  action="' . route('user.destroy', [$row->id]) . '">
                                <input type="hidden" name="_token" value="' . csrf_token() . '">
                                <input type="hidden" name="_method" value="DELETE">
                                <button type="submit" class="edit-delete-btn" style="outline: none;" title="Delete"><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-around">';
                        $btn .= '<a href="' . route('user.wallet', [$row->id]) . '" class="edit-delete-btn mr-2" title="Wallet">';
                        $btn .= '<i class="fa-solid fa-wallet fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= '<a href="' . route('user.edit', [$row->id]) . '" class="edit-delete-btn mr-2  title="Edit"">';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= $delete;
                        $btn .= '</a></div>';
                        return $btn;
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.user.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function create()
    {
        try {
            $params['data'] = [];
            return view('admin.user.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'full_name' => 'required|min:2',
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number',
                'email' => 'required|unique:tbl_user|email',
                'password' => 'required|min:4',
                'bio' => 'required',
                'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();

            $email_array = explode('@', $request->email);
            $requestData['user_name'] = $this->common->user_name($email_array[0]);
            $requestData['password'] = Hash::make($requestData['password']);
            $files = $requestData['image'];
            $requestData['image'] = $this->common->saveImage($files, $this->folder);
            $requestData['type'] = 4;
            $requestData['wallet_coin'] = 0;
            $requestData['device_type'] = 0;
            $requestData['device_token'] = "";
            $requestData['status'] = 1;

            $user_data = User::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($user_data->id)) {
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

            $params['data'] = User::where('id', $id)->first();
            if ($params['data'] != null) {

                $this->common->imageNameToUrl(array($params['data']), 'image', $this->folder);

                return view('admin.user.edit', $params);
            } else {
                return redirect()->back()->with('error', __('Label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update($id, Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'full_name' => 'required|min:2',
                'email' => 'required|email|unique:tbl_user,email,' . $id,
                'mobile_number' => 'required|numeric|unique:tbl_user,mobile_number,' . $id,
                'bio' => 'required',
                'image' => 'image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();

            if (isset($request['image'])) {
                $files = $request['image'];
                $requestData['image'] = $this->common->saveImage($files, $this->folder);

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }
            unset($requestData['old_image']);

            $User_data = User::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($User_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function destroy($id)
    {
        try {
            $data = User::where('id', $id)->first();
            if (isset($data)) {
                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();

                Follow::where('user_id', $id)->delete();
                History::where('user_id', $id)->delete();
                Like::where('user_id', $id)->delete();
                Read_Notification::where('user_id', $id)->delete();
                Reviews::where('user_id', $id)->delete();
                Comment::where('user_id', $id)->delete();
                Content_Play::where('user_id', $id)->delete();

                $threads = Threads::where('user_type', 1)->where('user_id', $id)->get();
                if ($threads != null && isset($threads)) {
                    for ($i = 0; $i < count($threads); $i++) {

                        Like::where('threads_id', $threads[$i]['id'])->delete();
                        Comment::where('threads_id', $threads[$i]['id'])->delete();

                        $this->common->deleteImageToFolder($this->threads, $threads[$i]['image']);
                        $threads[$i]->delete();
                    }
                }
            }
            return redirect()->route('user.index')->with('success', __('Label.data_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function wallet($id, Request $request)
    {
        try {

            $params['data'] = User::where('id', $id)->first();
            if ($params['data'] != null) {

                $params['id'] = $id;
                $params['total_transaction_coin'] = Wallet_Transaction::where('user_id', $id)->sum('coin');
                $params['total_reward_coin'] = Reward_Transaction::where('user_id', $id)->sum('coin');

                if ($request->ajax()) {

                    $data = Wallet_Transaction::where('user_id', $id)->with('user', 'content', 'episode')->latest()->orderby('id', 'desc')->get();

                    return DataTables()::of($data)
                        ->addIndexColumn()
                        ->addColumn('date', function ($row) {
                            $date = date("Y-m-d", strtotime($row->created_at));
                            return $date;
                        })
                        ->make(true);
                }

                return view('admin.user.wallet', $params);
            } else {
                return redirect()->back()->with('error', __('Label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
