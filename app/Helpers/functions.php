<?php

use App\Models\General_Setting;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Storage;

function settingData()
{
    $setting = General_Setting::get();
    $data = [];
    foreach ($setting as $value) {
        $data[$value->key] = $value->value;
    }
    return $data;
}
function App_Name()
{
    $data = settingData();
    $app_name = $data['app_name'];

    if (isset($app_name) && $app_name != "") {
        return $app_name;
    } else {
        return env('APP_NAME');
    }
}
function string_cut($string, $len)
{
    if (strlen($string) > $len) {
        $string = mb_substr(strip_tags($string), 0, $len, 'utf-8') . '...';
        // $string = substr(strip_tags($string),0,$len).'...';
    }
    return $string;
}
function tab_icon()
{
    $settingData = settingData();
    $name = $settingData['app_logo'];
    $folder = "app";

    if ($name != "" && $folder != "") {

        $appName = Config::get('app.image_url');

        if (Storage::disk('public')->exists($folder . '/' . $name)) {
            $data = $appName . $folder . '/' . $name;
        } else {
            $data = asset('assets/imgs/no_img.png');
        }
    } else {
        $data = asset('/assets/imgs/no_img.png');
    }
    return ($data);
}
function TimeToMilliseconds($str)
{

    $time = explode(":", $str);

    $hour = (int) $time[0] * 60 * 60 * 1000;
    $minute = (int) $time[1] * 60 * 1000;
    $sec = (int) $time[2] * 1000;
    $result = $hour + $minute + $sec;
    return $result;
}
function no_format($num)
{
    if ($num > 1000) {
        $x = round($num);
        $x_number_format = number_format($x);
        $x_array = explode(',', $x_number_format);
        $x_parts = array('K', 'M', 'B', 'T');
        $x_count_parts = count($x_array) - 1;
        $x_display = $x;
        $x_display = $x_array[0] . ((int) $x_array[1][0] !== 0 ? '.' . $x_array[1][0] : '');
        $x_display .= $x_parts[$x_count_parts - 1];

        return $x_display;
    }
    return $num;
}
function currency_code()
{
    $setting = settingData();
    return $setting['currency_code'];
}

// Artist
function Artist_Data()
{
    if (Auth::guard('artist')->user()) {
        return Auth::guard('artist')->user();
    } else {
        return redirect()->route('artist.logout');
    }
}

// Demo Mode
function Check_Admin_Access()
{
    if (env('DEMO_MODE') == 'ON') {
        return 0;
    } else {
        return 1;
    }
}
function Demo_Domain()
{
    $domain = request()->getHost();
    if ($domain == base64_decode('bG9jYWxob3N0') || $domain == base64_decode('ZHRwb2NrZXRmbS5kaXZpbmV0ZWNocy5pbg==') || $domain == base64_decode('ZHRwb2NrZXRmbS5kaXZpbmV0ZWNocy5jb20=')) {
        return 1;
    } else {
        return 0;
    }
}
function Item_Code()
{
    return base64_decode('NDYxOTIxNDk=');
}
