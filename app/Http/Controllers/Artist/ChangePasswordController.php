<?php

namespace App\Http\Controllers\Artist;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

class ChangePasswordController extends Controller
{
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
            $params['user_id'] = $artist['id'];

            return view('artist.changepassword.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update($id, Request $request)
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

            $artist = Artist::where('id', $id)->first();

            if (isset($artist) && $artist != null) {

                if (Hash::check($request['current_password'], $artist['password'])) {

                    $artist->password = Hash::make($request['new_password']);
                    if ($artist->save()) {
                        return response()->json(array('status' => 200, 'success' => 'Password Change Successfully.'));
                    }
                } else {
                    return response()->json(array('status' => 400, 'errors' => 'Please Enter Right Current Password.'));
                }
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
