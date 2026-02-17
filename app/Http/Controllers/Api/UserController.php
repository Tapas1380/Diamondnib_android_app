<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

// Login Type = 1 = OTP, 2 = Goggle, 3 = Apple, 4 = Normal
class UserController extends Controller
{
    private $folder_user = "user";
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

    public function login(Request $request)
    {
        try {

            if ($request->type == 1) {

                $validation = Validator::make(
                    $request->all(),
                    [
                        'mobile_number' => 'required|numeric',
                    ],
                    [
                        'mobile_number.required' => __('api_msg.mobile_number_is_required'),
                    ]
                );
            } elseif ($request->type == 2 || $request->type == 3) {

                $validation = Validator::make(
                    $request->all(),
                    [
                        'email' => 'required|email',
                    ],
                    [
                        'email.required' => __('api_msg.email_is_required'),
                    ]
                );
            } elseif ($request->type == 4) {

                $validation = Validator::make(
                    $request->all(),
                    [
                        'email' => 'required|email',
                        'password' => 'required|min:4',
                    ],
                    [
                        'email.required' => __('api_msg.email_is_required'),
                        'password.required' => __('api_msg.password_is_required'),
                    ]
                );
            } else {

                $validation = Validator::make(
                    $request->all(),
                    [
                        'type' => 'required|numeric',
                    ],
                    [
                        'type.required' => __('api_msg.type_is_required'),
                    ]
                );
            }
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $type = $request->type;
            $full_name = isset($request->full_name) ? $request->full_name : '';
            $email = isset($request->email) ? $request->email : '';
            $password = isset($request->password) ? Hash::make($request->password) : '';
            $mobile_number = isset($request->mobile_number) ? $request->mobile_number : '';
            $device_type = isset($request->device_type) ? $request->device_type : 0;
            $device_token = isset($request->device_token) ? $request->device_token : '';
            $image = '';
            if (isset($request['image']) && $request['image'] != null) {
                $file = $request->file('image');
                $image = $this->common->saveImage($file, $this->folder_user);
            }

            // OTP
            if ($type == 1) {

                $user = User::where('mobile_number', $mobile_number)->latest()->first();
                if (isset($user) && $user != null) {

                    // Update Device Token && Type
                    User::where('id', $user['id'])->update(['device_token' => $device_token]);
                    User::where('id', $user['id'])->update(['device_type' => $device_type]);
                    $user['device_type'] = $device_type;
                    $user['device_token'] = $device_token;

                    $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                    return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                } else {

                    $insert = array(
                        'user_name' => $this->common->user_name($mobile_number),
                        'full_name' => $full_name,
                        'email' => $email,
                        'password' => $password,
                        'mobile_number' => $mobile_number,
                        'image' => $image,
                        'type' => $type,
                        'bio' => $this->common->user_tag_line(),
                        'wallet_coin' => 0,
                        'device_type' => $device_type,
                        'device_token' => $device_token,
                        'status' => 1,
                    );
                    $user_id = User::insertGetId($insert);

                    if (isset($user_id)) {

                        $user = User::where('id', $user_id)->first();
                        if (isset($user)) {

                            $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                            return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                        } else {
                            return $this->common->API_Response(400, __('api_msg.data_not_found'));
                        }
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_save'));
                    }
                }
            }

            // Google || Apple
            if ($type == 2 || $type == 3) {

                $user = User::where('email', $email)->latest()->first();
                if (isset($user) && $user != null) {

                    // Update Device Token && Type
                    User::where('id', $user['id'])->update(['device_token' => $device_token]);
                    User::where('id', $user['id'])->update(['device_type' => $device_type]);
                    $user['device_type'] = $device_type;
                    $user['device_token'] = $device_token;

                    $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                    return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                } else {

                    $user_name = explode('@', $email);
                    $insert = array(
                        'user_name' => $this->common->user_name($user_name[0]),
                        'full_name' => $full_name,
                        'email' => $email,
                        'password' => $password,
                        'mobile_number' => $mobile_number,
                        'image' => $image,
                        'type' => $type,
                        'bio' => $this->common->user_tag_line(),
                        'wallet_coin' => 0,
                        'device_type' => $device_type,
                        'device_token' => $device_token,
                        'status' => 1,
                    );
                    $user_id = User::insertGetId($insert);

                    if (isset($user_id)) {

                        $user = User::where('id', $user_id)->first();
                        if (isset($user)) {

                            $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                            // Send Mail (Type = 1- Register Mail, 2 Transaction Mail)
                            if ($type == 2) {
                                $this->common->Send_Mail(1, $user->email);
                            }

                            return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                        } else {
                            return $this->common->API_Response(400, __('api_msg.data_not_found'));
                        }
                    } else {
                        return $this->common->API_Response(400, __('api_msg.data_not_save'));
                    }
                }
            }

            // Normal
            if ($type == 4) {

                $user = User::where('email', $email)->latest()->first();
                if (isset($user)) {

                    if (Hash::check($request->password, $user->password)) {

                        // Update Device Token && Type
                        User::where('id', $user['id'])->update(['device_token' => $device_token]);
                        User::where('id', $user['id'])->update(['device_type' => $device_type]);
                        $user['device_type'] = $device_type;
                        $user['device_token'] = $device_token;

                        $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                        return $this->common->API_Response(200, __('api_msg.login_successfully'), array($user));
                    } else {
                        return $this->common->API_Response(400, __('api_msg.email_pass_worng'));
                    }
                } else {
                    return $this->common->API_Response(400, __('api_msg.email_pass_worng'));
                }
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function logout(Request $request)
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

            $user_id = $request->user_id;
            $data = User::where('id', $user_id)->first();

            $array = array();
            if (!empty($data) && isset($data) && $data != null) {

                $array['device_type'] = 0;
                $array['device_token'] = "";
                User::where('id', $user_id)->update($array);

                return $this->common->API_Response(200, __('api_msg.logout_successfully'));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_profile(Request $request)
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

            $user_id = $request->user_id;

            $user_data = user::where('id', $user_id)->first();
            if (!empty($user_data)) {

                $this->common->imageNameToUrl(array($user_data), 'image', $this->folder_user);

                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), array($user_data));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update_profile(Request $request)
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

            $user_id = $request->user_id;

            $array = array();
            $data = User::where('id', $user_id)->first();
            if (!empty($data)) {

                if (isset($request->user_name) && $request->user_name != '') {

                    $check = User::where('user_name', $request->user_name)->first();
                    if (isset($check) && $check != null) {
                        if ($check->id == $data->id) {
                            $array['user_name'] = $request->user_name;
                        } else {
                            return $this->common->API_Response(400, __('api_msg.user_name_exists'));
                        }
                    } else {
                        $array['user_name'] = $request->user_name;
                    }
                }
                if (isset($request->full_name) && $request->full_name != '') {
                    $array['full_name'] = $request->full_name;
                }
                if (isset($request->email) && $request->email != '') {
                    $array['email'] = $request->email;
                }
                if (isset($request->password) && $request->password != '') {
                    $array['password'] = hash::make($request->password);
                }
                if (isset($request->mobile_number) && $request->mobile_number != '') {
                    $array['mobile_number'] = $request->mobile_number;
                }
                if (isset($request->image) && $request->file('image') != '') {

                    $image = $request->file('image');
                    $array['image'] = $this->common->saveImage($image, $this->folder_user);

                    $old_image = $data['image'];
                    $this->common->deleteImageToFolder($this->folder_user, $old_image);
                }
                if (isset($request->bio) && $request->bio != '') {
                    $array['bio'] = $request->bio;
                }
                if (isset($request->device_type) && $request->device_type != '') {
                    $array['device_type'] = $request->device_type;
                }
                if (isset($request->device_token) && $request->device_token != '') {
                    $array['device_token'] = $request->device_token;
                }

                User::where('id', $user_id)->update($array);

                $user = User::where('id', $user_id)->first();
                $this->common->imageNameToUrl(array($user), 'image', $this->folder_user);

                return $this->common->API_Response(200, __('api_msg.profile_update_successfully'), array($user));
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
