<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Category;
use App\Models\Common;
use App\Models\Language;
use App\Models\Music_Section;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class MusicSectionController extends Controller
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
            $params['language'] = Language::latest()->get();
            $params['artist'] = Artist::latest()->get();

            return view('admin.music_section.index', $params);
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
                'title' => 'required',
                'language_id' => 'required',
                'artist_id' => 'required',
                'order_by_play' => 'required',
                'order_by_upload' => 'required',
                'view_all' => 'required',
                'screen_layout' => 'required',
                'no_of_content' => 'required|numeric|min:1'
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            if ($request['is_home_screen'] == 1) {
                $validator1 = Validator::make($request->all(), [
                    'category_id' => 'required',
                ]);
                if ($validator1->fails()) {
                    $errs1 = $validator1->errors()->all();
                    return response()->json(array('status' => 400, 'errors' => $errs1));
                }
            } else {
                $request['category_id'] = $request['top_category_id'];
            }

            $requestData = $request->all();
            $requestData['short_title'] = isset($request->short_title) ? $request->short_title : '';
            $requestData['sortable'] = 1;
            $requestData['status'] = 1;

            $section_data = Music_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($section_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function GetSectionData(Request $request)
    {
        try {

            $data = Music_Section::where('is_home_screen', $request->is_home_screen)->where('top_category_id', $request->top_category_id)->orderBy('sortable', 'asc')->latest()->get();
            return response()->json(array('status' => 200, 'success' => 'Data Get Successfully', 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function SectionDataEdit(Request $request)
    {
        try {

            $data = Music_Section::where('id', $request['id'])->first();
            return response()->json(array('status' => 200, 'success' => 'Data Get Successfully', 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update($id, Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required',
                'artist_id' => 'required',
                'language_id' => 'required',
                'order_by_play' => 'required',
                'order_by_upload' => 'required',
                'view_all' => 'required',
                'screen_layout' => 'required',
                'no_of_content' => 'required|numeric|min:1'
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();
            $requestData['short_title'] = isset($request->short_title) ? $request->short_title : '';

            $section_data = Music_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($section_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function show($id)
    {
        try {

            Music_Section::where('id', $id)->delete();
            return response()->json(array('status' => 200, 'success' => __('Label.data_delete_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    // Sortable
    public function SectionSortable(Request $request)
    {
        try {

            $data = Music_Section::select('id', 'title')->where('is_home_screen', $request->is_home_screen)->where('top_category_id', $request->top_category_id)->orderBy('sortable', 'asc')->latest()->get();
            return response()->json(array('status' => 200, 'success' => 'Data Get Successfully', 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function SectionSortableSave(Request $request)
    {
        try {

            $ids = $request['ids'];
            if (isset($ids) && $ids != null && $ids != "") {

                $id_array = explode(',', $ids);
                for ($i = 0; $i < count($id_array); $i++) {
                    Music_Section::where('id', $id_array[$i])->update(['sortable' => $i + 1]);
                }
            }

            return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
