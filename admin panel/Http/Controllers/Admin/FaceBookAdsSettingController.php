<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\General_Setting;
use Illuminate\Http\Request;
use Exception;

class FaceBookAdsSettingController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $data = settingData();
            if ($data) {
                return view('admin.facebook_ads.index', ['result' => $data]);
            } else {
                return redirect()->back()->with('error', __('Label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function facebookadAndroid(Request $request)
    {
        try {

            $data = $request->all();
            $data["fb_native_id"] = isset($data['fb_native_id']) ? $data['fb_native_id'] : '';
            $data["fb_banner_id"] = isset($data['fb_banner_id']) ? $data['fb_banner_id'] : '';
            $data["fb_interstiatial_id"] = isset($data['fb_interstiatial_id']) ? $data['fb_interstiatial_id'] : '';
            $data["fb_rewardvideo_id"] = isset($data['fb_rewardvideo_id']) ? $data['fb_rewardvideo_id'] : '';
            $data["fb_native_full_id"] = isset($data['fb_native_full_id']) ? $data['fb_native_full_id'] : '';

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
    public function facebookadIos(Request $request)
    {
        try {

            $data = $request->all();
            $data["fb_ios_native_id"] = isset($data['fb_ios_native_id']) ? $data['fb_ios_native_id'] : '';
            $data["fb_ios_banner_id"] = isset($data['fb_ios_banner_id']) ? $data['fb_ios_banner_id'] : '';
            $data["fb_ios_interstiatial_id"] = isset($data['fb_ios_interstiatial_id']) ? $data['fb_ios_interstiatial_id'] : '';
            $data["fb_ios_rewardvideo_id"] = isset($data['fb_ios_rewardvideo_id']) ? $data['fb_ios_rewardvideo_id'] : '';
            $data["fb_ios_native_full_id"] = isset($data['fb_ios_native_full_id']) ? $data['fb_ios_native_full_id'] : '';

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
}
