<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];
            $params['data'] = Admin::latest()->first();

            return view('admin.profile.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_name' => 'required|min:4',
                'email' => 'required|email',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();

            $check_admin = Admin::where('id', $requestData['id'])->first();
            if (isset($check_admin) && $check_admin != null) {

                Admin::where('id', $requestData['id'])->update(['user_name' => $requestData['user_name'], 'email' => $requestData['email']]);
                return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
            } else {
                return redirect()->route('admin.logout');
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function ChangePassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'current_password' => 'required',
                'new_password' => 'required|min:4',
                'confirm_password' => 'required|min:4|same:new_password',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $check_admin = Admin::where('id', $request['id'])->first();
            if (isset($check_admin) && $check_admin != null) {

                if (Hash::check($request['current_password'], $check_admin['password'])) {

                    $check_admin->password = Hash::make($request['new_password']);
                    if ($check_admin->save()) {
                        return response()->json(array('status' => 200, 'success' => 'Password Change Successfully.'));
                    }
                } else {
                    return response()->json(array('status' => 400, 'errors' => 'Please Enter Right Current Password.'));
                }
            } else {
                return redirect()->route('admin.logout');
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
