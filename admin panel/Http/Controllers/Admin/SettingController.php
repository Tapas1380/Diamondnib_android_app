<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\General_Setting;
use App\Models\Smtp_Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class SettingController extends Controller
{
    private $folder = "app";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $setting = General_Setting::get();
            foreach ($setting as $row) {
                $data[$row->key] = $row->value;
            }
            $data['app_logo'] = $this->common->getImage($this->folder, $data['app_logo']);
            if (isset($data['home_popup_video']) && $data['home_popup_video'] != '') {
                $data['home_popup_video'] = $this->common->getImage($this->folder, $data['home_popup_video']);
            }

            if ($data) {

                $smtp = Smtp_Setting::latest()->first();
                return view('admin.setting.index', ['result' => $data, 'smtp' => $smtp]);
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function app(Request $request)
    {
        try {

            $data = $request->all();
            $data["app_name"] = isset($data['app_name']) ? $data['app_name'] : '';
            $data["host_email"] = isset($data['host_email']) ? $data['host_email'] : '';
            $data["app_version"] = isset($data['app_version']) ? $data['app_version'] : '';
            $data["author"] = isset($data['author']) ? $data['author'] : '';
            $data["email"] = isset($data['email']) ? $data['email'] : '';
            $data["contact"] = isset($data['contact']) ? $data['contact'] : '';
            $data["app_desripation"] = isset($data['app_desripation']) ? $data['app_desripation'] : '';
            $data["website"] = isset($data['website']) ? $data['website'] : '';

            if ($request->hasFile('app_logo')) {
                $files = $request->file('app_logo');
                $data['app_logo'] = $this->common->saveImage($files, $this->folder);
                $this->common->deleteImageToFolder($this->folder, basename($data['old_app_logo']));
            }

            if ($request->hasFile('home_popup_video')) {
                $files = $request->file('home_popup_video');
                $data['home_popup_video'] = $this->common->saveImage($files, $this->folder);
                $this->common->deleteImageToFolder($this->folder, basename($data['old_home_popup_video']));
            }

            unset($data['_token']);
            unset($data['old_app_logo']);
            unset($data['old_home_popup_video']);

            foreach ($data as $key => $value) {
                if ($value === null) {
                    continue;
                }
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                } else {
                    $insert = new General_Setting();
                    $insert->key = $key;
                    $insert->value = $value;
                    $insert->save();
                }
            }
            return response()->json(array('status' => 200, 'success' => __('Label.save_setting')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function currency(Request $request)
    {
        try {

            $data = $request->all();
            $data["currency"] = isset($data['currency']) ? strtoupper($data['currency']) : '';
            $data["currency_code"] = isset($data['currency_code']) ? $data['currency_code'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(array('status' => 200, 'success' => __('Label.save_setting')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function smtpSave(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'status' => 'required',
                'host' => 'required',
                'port' => 'required',
                'protocol' => 'required',
                'user' => 'required',
                'pass' => 'required',
                'from_name' => 'required',
                'from_email' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            if (isset($request->id) && $request->id != null && $request->id != "") {

                $smtp = Smtp_Setting::where('id', $request->id)->first();
                if (isset($smtp->id)) {
                    $smtp->protocol = $request->protocol;
                    $smtp->host = $request->host;
                    $smtp->port = $request->port;
                    $smtp->user = $request->user;
                    $smtp->pass = $request->pass;
                    $smtp->from_name = $request->from_name;
                    $smtp->from_email = $request->from_email;
                    $smtp->status = $request->status;
                    if ($smtp->save()) {
                        return response()->json(array('status' => 200, 'success' => __('Label.save_setting')));
                    } else {
                        return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
                    }
                }
            } else {

                $insert = new Smtp_Setting();
                $insert->protocol = $request->protocol;
                $insert->host = $request->host;
                $insert->port = $request->port;
                $insert->user = $request->user;
                $insert->pass = $request->pass;
                $insert->from_name = $request->from_name;
                $insert->from_email = $request->from_email;
                $insert->status = $request->status;
                if ($insert->save()) {

                    $this->common->SetSmtpConfig();
                    return response()->json(array('status' => 200, 'success' => __('Label.save_setting')));
                } else {
                    return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
                }
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
