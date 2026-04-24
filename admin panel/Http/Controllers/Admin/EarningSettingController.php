<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reward_Coin;
use Illuminate\Http\Request;
use Exception;

class EarningSettingController extends Controller
{
    public function index()
    {
        try {

            $reward_coin = Reward_Coin::get();
            foreach ($reward_coin as $row) {
                $reward_coin[$row->key] = $row->value;
            }
            return view('admin.setting.earning_setting', ['reward_coin' => $reward_coin]);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function dailyLoginPoint(Request $request)
    {
        try {

            $data = $request->all();
            $data["Day-1"] = isset($data['Day-1']) ? $data['Day-1'] : 0;
            $data["Day-2"] = isset($data['Day-2']) ? $data['Day-2'] : 0;
            $data["Day-3"] = isset($data['Day-3']) ? $data['Day-3'] : 0;
            $data["Day-4"] = isset($data['Day-4']) ? $data['Day-4'] : 0;
            $data["Day-5"] = isset($data['Day-5']) ? $data['Day-5'] : 0;
            $data["Day-6"] = isset($data['Day-6']) ? $data['Day-6'] : 0;
            $data["Day-7"] = isset($data['Day-7']) ? $data['Day-7'] : 0;

            foreach ($data as $key => $value) {
                $setting = Reward_Coin::where('key', $key)->first();
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
    public function spinWheelPoint(Request $request)
    {
        try {

            $data = $request->all();
            $data["1"] = isset($data['1']) ? $data['1'] : 0;
            $data["2"] = isset($data['2']) ? $data['2'] : 0;
            $data["3"] = isset($data['3']) ? $data['3'] : 0;
            $data["4"] = isset($data['4']) ? $data['4'] : 0;
            $data["5"] = isset($data['5']) ? $data['5'] : 0;
            $data["6"] = isset($data['6']) ? $data['6'] : 0;

            foreach ($data as $key => $value) {
                $setting = Reward_Coin::where('key', $key)->first();
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
    public function getFreeCongPoint(Request $request)
    {
        try {

            $data = $request->all();
            $data["free-coin"] = isset($data['free-coin']) ? $data['free-coin'] : 0;

            foreach ($data as $key => $value) {
                $setting = Reward_Coin::where('key', $key)->first();
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
