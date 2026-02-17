<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class BannerController extends Controller
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
            $params['category'] = Category::latest()->get();

            return view('admin.banner.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function typeByContent(Request $request)
    {
        try {

            $data = [];
            if ($request['is_home_screen'] == 1) {

                if ($request['content_type'] == 1 || $request['content_type'] == 2) {

                    $bannerlist = Banner::where('is_home_screen', 1)->where('section_type', 1)->get();
                    $bannerIds = [];
                    for ($i = 0; $i < count($bannerlist); $i++) {
                        $bannerIds[] = $bannerlist[$i]['content_id'];
                    }
                    $data = Content::whereNotIn('id', $bannerIds)->where('content_type', $request['content_type'])->where('status', 1)->latest()->get();
                }
            } else if ($request['is_home_screen'] == 2) {

                if ($request['content_type'] == 1 || $request['content_type'] == 2) {

                    $bannerlist = Banner::where('is_home_screen', 2)->where('section_type', 1)->get();
                    $bannerIds = [];
                    for ($i = 0; $i < count($bannerlist); $i++) {
                        $bannerIds[] = $bannerlist[$i]['content_id'];
                    }
                    $data = Content::whereNotIn('id', $bannerIds)->where('content_type', $request['content_type'])->where('category_id', $request['top_category_id'])->where('status', 1)->latest()->get();
                }
            }
            return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully'), 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'is_home_screen' => 'required',
                'top_category_id' => 'required',
                'content_type' => 'required',
                'content_id' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $banner = new Banner();
            $banner['section_type'] = 1;
            $banner['is_home_screen'] = $request['is_home_screen'];
            $banner['top_category_id'] = $request['top_category_id'];
            $banner['content_type'] = $request['content_type'];
            $banner['content_id'] = $request['content_id'];
            $banner['status'] = 1;
            if ($banner->save()) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function BannerList(Request $request)
    {
        try {

            if ($request['is_home_screen'] == 1) {
                $data = Banner::where('is_home_screen', $request['is_home_screen'])->where('section_type', 1)->with('content')->orderBy('id', 'desc')->get();
            } else {
                $data = Banner::where('top_category_id', $request['top_category_id'])->where('is_home_screen', $request['is_home_screen'])->where('section_type', 1)->with('content')->orderBy('id', 'desc')->get();
            }

            return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully'), 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function destroy($id)
    {
        try {

            Banner::where('id', $id)->delete();
            return response()->json(array('status' => 200, 'success' => __('Label.data_delete_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
