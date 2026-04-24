<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

// Login Type = 1 = OTP, 2 = Google, 3 = Apple, 4 = Normal
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
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    public function login(Request $request)
    {
        try {

            // ─── Validation per type ───────────────────────────────────────
            if ($request->type == 1) {
                $validation = Validator::make($request->all(), [
                    'mobile_number' => 'required|numeric',
                ], [
                    'mobile_number.required' => __('api_msg.mobile_number_is_required'),
                ]);

            } elseif ($request->type == 2 || $request->type == 3) {
                $validation = Validator::make($request->all(), [
                    'email' => 'required|email',
                ], [
                    'email.required' => __('api_msg.email_is_required'),
                ]);

            } elseif ($request->type == 4) {
                $validation = Validator::make($request->all(), [
                    'email'    => 'required|email',
                    'password' => 'required|min:4',
                ], [
                    'email.required'    => __('api_msg.email_is_required'),
                    'password.required' => __('api_msg.password_is_required'),
                ]);

            } else {
                $validation = Validator::make($request->all(), [
                    'type' => 'required|numeric',
                ], [
                    'type.required' => __('api_msg.type_is_required'),
                ]);
            }

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            // ─── Common fields ─────────────────────────────────────────────
            $type          = $request->type;
            $full_name     = $request->full_name     ?? '';
            $email         = $request->email         ?? '';
            $mobile_number = $request->mobile_number ?? '';
            $is_register   = isset($request->is_register) ? (int) $request->is_register : 0;
            $device_type   = $request->device_type   ?? 0;
            $device_token  = $request->device_token  ?? '';

            // ✅ FIX: Always use a safe empty-string default for password
            //    (avoids NULL constraint errors on the users table)
            $password = !empty($request->password) ? Hash::make($request->password) : '';

            // Image upload
            $image = '';
            if (!empty($request['image'])) {
                $image = $this->common->saveImage($request->file('image'), $this->folder_user);
            }

            // ══════════════════════════════════════════════════════════════
            //  TYPE 1 — OTP
            // ══════════════════════════════════════════════════════════════
            if ($type == 1) {

                $user = User::where('mobile_number', $mobile_number)->latest()->first();

                if ($user) {
                    User::where('id', $user->id)->update([
                        'device_token' => $device_token,
                        'device_type'  => $device_type,
                    ]);
                    $user->device_type  = $device_type;
                    $user->device_token = $device_token;
                    $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                    return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
                }

                $user_id = User::insertGetId([
                    'user_name'     => $this->common->user_name($mobile_number),
                    'full_name'     => $full_name,
                    'email'         => $email,
                    'password'      => $password,   // safe empty string if not provided
                    'mobile_number' => $mobile_number,
                    'image'         => $image,
                    'type'          => $type,
                    'bio'           => $this->common->user_tag_line(),
                    'wallet_coin'   => 0,
                    'device_type'   => $device_type,
                    'device_token'  => $device_token,
                    'status'        => 1,
                ]);

                $user = User::find($user_id);
                if (!$user) return $this->common->API_Response(400, __('api_msg.data_not_found'));

                $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
            }

            // ══════════════════════════════════════════════════════════════
            //  TYPE 2 (Google) || TYPE 3 (Apple)
            // ══════════════════════════════════════════════════════════════
            if ($type == 2 || $type == 3) {

                // ✅ FIX: Validate email is not empty (extra safety for Apple relay)
                if (empty(trim($email))) {
                    return $this->common->API_Response(400, 'Email is required for social login.');
                }

                $user = User::where('email', $email)->latest()->first();

                if ($user) {
                    // Existing user — just refresh device info
                    User::where('id', $user->id)->update([
                        'device_token' => $device_token,
                        'device_type'  => $device_type,
                    ]);
                    $user->device_type  = $device_type;
                    $user->device_token = $device_token;
                    $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                    return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
                }

                // ✅ FIX: New social user — password must NOT be null.
                //    Use a random secure string so the column constraint is satisfied.
                //    Social users never use this password (they login via token).
                $user_name_parts = explode('@', $email);
                $user_id = User::insertGetId([
                    'user_name'     => $this->common->user_name($user_name_parts[0] ?? $email),
                    'full_name'     => !empty($full_name) ? $full_name : ($user_name_parts[0] ?? 'User'),
                    'email'         => $email,
                    'password'      => Hash::make(Str::random(32)), // ✅ random — never used for social login
                    'mobile_number' => $mobile_number,
                    'image'         => $image,
                    'type'          => $type,
                    'bio'           => $this->common->user_tag_line(),
                    'wallet_coin'   => 0,
                    'device_type'   => $device_type,
                    'device_token'  => $device_token,
                    'status'        => 1,
                ]);

                $user = User::find($user_id);
                if (!$user) return $this->common->API_Response(400, __('api_msg.data_not_found'));

                $this->common->imageNameToUrl([$user], 'image', $this->folder_user);

                // Send welcome mail for Google (type 2) only
                if ($type == 2) {
                    $this->common->Send_Mail(1, $user->email);
                }

                return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
            }

            // ══════════════════════════════════════════════════════════════
            //  TYPE 4 — Normal (email + password)
            // ══════════════════════════════════════════════════════════════
            if ($type == 4) {

                $user = User::where('email', $email)->latest()->first();

                if ($user) {

                    $storedPassword  = $user->password ?? '';
                    $hasBcryptHash   = !empty($storedPassword)
                        && (str_starts_with($storedPassword, '$2y$')
                            || str_starts_with($storedPassword, '$2a$')
                            || str_starts_with($storedPassword, '$2b$'));

                    // User was created via social — no usable password set yet
                    if (!$hasBcryptHash) {
                        if ($is_register != 1) {
                            return $this->common->API_Response(
                                400,
                                'Password not set for this account. Please login with Google/Apple or register to set a password.'
                            );
                        }

                        // Register flow: set password for existing social account
                        $updateData = [
                            'password'     => Hash::make($request->password),
                            'device_token' => $device_token,
                            'device_type'  => $device_type,
                        ];
                        if (!empty($full_name) && empty($user->full_name)) {
                            $updateData['full_name'] = $full_name;
                        }
                        User::where('id', $user->id)->update($updateData);

                        $user = User::find($user->id);
                        $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                        return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
                    }

                    // Normal password check
                    if (Hash::check($request->password, $user->password)) {
                        User::where('id', $user->id)->update([
                            'device_token' => $device_token,
                            'device_type'  => $device_type,
                        ]);
                        $user->device_type  = $device_type;
                        $user->device_token = $device_token;
                        $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                        return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
                    }

                    return $this->common->API_Response(400, __('api_msg.email_pass_worng'));

                } else {

                    // No user found — only create if explicit register call
                    if ($is_register != 1) {
                        return $this->common->API_Response(400, 'Email not registered. Please sign up first.');
                    }

                    $user_name_parts = explode('@', $email);
                    $user_id = User::insertGetId([
                        'user_name'     => $this->common->user_name($user_name_parts[0] ?? $email),
                        'full_name'     => $full_name,
                        'email'         => $email,
                        'password'      => Hash::make($request->password),
                        'mobile_number' => $mobile_number,
                        'image'         => $image,
                        'type'          => $type,
                        'bio'           => $this->common->user_tag_line(),
                        'wallet_coin'   => 0,
                        'device_type'   => $device_type,
                        'device_token'  => $device_token,
                        'status'        => 1,
                    ]);

                    $user = User::find($user_id);
                    if (!$user) return $this->common->API_Response(400, __('api_msg.data_not_found'));

                    $this->common->imageNameToUrl([$user], 'image', $this->folder_user);
                    return $this->common->API_Response(200, __('api_msg.login_successfully'), [$user]);
                }
            }

        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  Forgot Password — send 6-digit reset code
    // ══════════════════════════════════════════════════════════════════════
    public function forgot_password(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'email' => 'required|email',
            ], [
                'email.required' => __('api_msg.email_is_required'),
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $user = User::where('email', $request->email)->latest()->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $resetCode = rand(100000, 999999);
            User::where('id', $user->id)->update([
                'reset_code'        => $resetCode,
                'reset_code_expiry' => now()->addMinutes(10),
            ]);

            $details = [
                'title' => 'Password Reset Code',
                'body'  => 'Your password reset code is: ' . $resetCode,
            ];

            Mail::send('mail.mail', ['details' => $details], function ($message) use ($request, $details) {
                $message->to($request->email)->subject($details['title']);
            });

            return $this->common->API_Response(200, 'Reset code sent to your email.');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  Verify Reset Code & set new password
    // ══════════════════════════════════════════════════════════════════════
    public function verify_reset_code(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'email'            => 'required|email',
                'code'             => 'required',
                'new_password'     => 'required|min:4',
                'confirm_password' => 'required|same:new_password',
            ], [
                'email.required'            => __('api_msg.email_is_required'),
                'code.required'             => 'Reset code is required',
                'new_password.required'     => 'New password is required',
                'confirm_password.required' => 'Confirm password is required',
                'confirm_password.same'     => 'Passwords do not match',
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $user = User::where('email', $request->email)->latest()->first();
            if (!$user) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            if (empty($user->reset_code) || $user->reset_code != $request->code) {
                return $this->common->API_Response(400, 'Invalid reset code.');
            }

            if (empty($user->reset_code_expiry) || now()->gt($user->reset_code_expiry)) {
                return $this->common->API_Response(400, 'Reset code has expired.');
            }

            User::where('id', $user->id)->update([
                'password'          => Hash::make($request->new_password),
                'reset_code'        => null,
                'reset_code_expiry' => null,
            ]);

            return $this->common->API_Response(200, 'Password changed successfully.');
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  Logout
    // ══════════════════════════════════════════════════════════════════════
    public function logout(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ], [
                'user_id.required' => __('api_msg.user_id_is_required'),
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $data = User::where('id', $request->user_id)->first();
            if (!$data) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            User::where('id', $request->user_id)->update([
                'device_type'  => 0,
                'device_token' => '',
            ]);

            return $this->common->API_Response(200, __('api_msg.logout_successfully'));
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  Get Profile
    // ══════════════════════════════════════════════════════════════════════
    public function get_profile(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ], [
                'user_id.required' => __('api_msg.user_id_is_required'),
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $user_data = User::where('id', $request->user_id)->first();
            if (!$user_data) {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }

            $this->common->imageNameToUrl([$user_data], 'image', $this->folder_user);
            return $this->common->API_Response(200, __('api_msg.get_record_successfully'), [$user_data]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  Update Profile
    // ══════════════════════════════════════════════════════════════════════
    public function update_profile(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
            ], [
                'user_id.required' => __('api_msg.user_id_is_required'),
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $data = User::where('id', $request->user_id)->first();
            if (!$data) {
                return $this->common->API_Response(400, __('api_msg.data_not_save'));
            }

            $array = [];

            if (!empty($request->user_name)) {
                $check = User::where('user_name', $request->user_name)->first();
                if ($check && $check->id != $data->id) {
                    return $this->common->API_Response(400, __('api_msg.user_name_exists'));
                }
                $array['user_name'] = $request->user_name;
            }
            if (!empty($request->full_name))     $array['full_name']     = $request->full_name;
            if (!empty($request->email))          $array['email']         = $request->email;
            if (!empty($request->password))       $array['password']      = Hash::make($request->password);
            if (!empty($request->mobile_number))  $array['mobile_number'] = $request->mobile_number;
            if (!empty($request->bio))            $array['bio']           = $request->bio;
            if (!empty($request->device_type))    $array['device_type']   = $request->device_type;
            if (!empty($request->device_token))   $array['device_token']  = $request->device_token;

            if ($request->hasFile('image')) {
                $array['image'] = $this->common->saveImage($request->file('image'), $this->folder_user);
                $this->common->deleteImageToFolder($this->folder_user, $data['image']);
            }

            User::where('id', $request->user_id)->update($array);

            $user = User::find($request->user_id);
            $this->common->imageNameToUrl([$user], 'image', $this->folder_user);

            return $this->common->API_Response(200, __('api_msg.profile_update_successfully'), [$user]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}