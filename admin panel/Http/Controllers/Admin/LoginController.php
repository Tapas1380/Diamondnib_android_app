<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class LoginController extends Controller
{
    protected $redirectTo = 'admin/login';
    public function __construct()
    {
        try {
            $this->middleware('guest', ['except' => 'logout']);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    public function login(Request $request)
    {
        try {
            Auth()->guard('admin')->logout();
            return view('admin.login.login');
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function save_login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required',
                'password' => 'required|min:4',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();
            if (Auth()->guard('admin')->attempt(['email' => $requestData['email'], 'password' => $requestData['password']])) {

                $user = auth()->guard('admin')->user();
                if ($user->type == 1) {
                    $this->middleware('checkadmin');
                }

                return response()->json(array('status' => 200, 'success' => __('Label.success_login')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.error_login')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function logout()
    {
        try {
            Auth()->guard('admin')->logout();
            return redirect()->route('admin.login')->with('success', __('Label.logout_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
