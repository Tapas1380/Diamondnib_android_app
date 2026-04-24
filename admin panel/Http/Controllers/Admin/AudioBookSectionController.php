<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Category;
use App\Models\Common;
use App\Models\Content_Section;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class AudioBookSectionController extends Controller
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

            return view('admin.audiobook_section.index', $params);
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
                'title' => 'required',
                'screen_layout' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            if ($request['is_home_screen'] != 1) {
                $request['category_id'] = $request['top_category_id'];
            }

            if ($request['content_type'] == 1 || $request['content_type'] == 2) {
                $validator1 = Validator::make($request->all(), [
                    'artist_id' => 'required',
                    'language_id' => 'required',
                    'category_id' => 'required',
                    'no_of_content' => 'required|numeric|min:1',
                    'order_by_upload' => 'required',
                    'order_by_play' => 'required',
                    'view_all' => 'required',
                ]);
                if ($validator1->fails()) {
                    $errs1 = $validator1->errors()->all();
                    return response()->json(array('status' => 400, 'errors' => $errs1));
                }
            }

            $requestData = $request->all();
            $requestData['section_type'] = 2;
            $requestData['short_title'] = isset($request->short_title) ? $request->short_title : '';
            $requestData['sortable'] = 1;
            $requestData['status'] = 1;

            $requestData['category_id'] = 0;
            $requestData['language_id'] = 0;
            $requestData['artist_id'] = 0;
            $requestData['order_by_play'] = 0;
            $requestData['order_by_upload'] = 0;
            $requestData['no_of_content'] = 0;
            $requestData['view_all'] = 0;
            if ($requestData['content_type'] == 1 || $requestData['content_type'] == 2) {

                $requestData['category_id'] = isset($request->category_id) ? $request->category_id : 0;
                $requestData['language_id'] = isset($request->language_id) ? $request->language_id : 0;
                $requestData['artist_id'] = isset($request->artist_id) ? $request->artist_id : 0;
                $requestData['order_by_play'] = isset($request->order_by_play) ? $request->order_by_play : 0;
                $requestData['order_by_upload'] = isset($request->order_by_upload) ? $request->order_by_upload : 0;
                $requestData['no_of_content'] = isset($request->no_of_content) ? $request->no_of_content : 0;
                $requestData['view_all'] = isset($request->view_all) ? $request->view_all : 0;
            }

            $section_data = Content_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
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

            $data = Content_Section::where('section_type', 2)->where('is_home_screen', $request->is_home_screen)->where('top_category_id', $request->top_category_id)->orderBy('sortable', 'asc')->latest()->get();
            return response()->json(array('status' => 200, 'success' => 'Data Get Successfully', 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function SectionDataEdit(Request $request)
    {
        try {

            $data = Content_Section::where('id', $request['id'])->first();
            return response()->json(array('status' => 200, 'success' => 'Data Get Successfully', 'result' => $data));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update($id, Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'content_type' => 'required',
                'title' => 'required',
                'screen_layout' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }
            if ($request['content_type'] == 1 || $request['content_type'] == 2) {
                $validator1 = Validator::make($request->all(), [
                    'artist_id' => 'required',
                    'language_id' => 'required',
                    'category_id' => 'required',
                    'no_of_content' => 'required|numeric|min:1',
                    'order_by_upload' => 'required',
                    'order_by_play' => 'required',
                    'view_all' => 'required',
                ]);
                if ($validator1->fails()) {
                    $errs1 = $validator1->errors()->all();
                    return response()->json(array('status' => 400, 'errors' => $errs1));
                }
            }

            $requestData = $request->all();
            $requestData['short_title'] = isset($request->short_title) ? $request->short_title : '';

            $requestData['artist_id'] = 0;
            $requestData['language_id'] = 0;
            $requestData['category_id'] = 0;
            $requestData['no_of_content'] = 0;
            $requestData['order_by_upload'] = 0;
            $requestData['order_by_play'] = 0;
            $requestData['view_all'] = 0;
            if ($requestData['content_type'] == 1 || $requestData['content_type'] == 2) {

                $requestData['artist_id'] = isset($request->artist_id) ? $request->artist_id : 0;
                $requestData['language_id'] = isset($request->language_id) ? $request->language_id : 0;
                $requestData['category_id'] = isset($request->category_id) ? $request->category_id : 0;
                $requestData['no_of_content'] = isset($request->no_of_content) ? $request->no_of_content : 0;
                $requestData['order_by_upload'] = isset($request->order_by_upload) ? $request->order_by_upload : 0;
                $requestData['order_by_play'] = isset($request->order_by_play) ? $request->order_by_play : 0;
                $requestData['view_all'] = isset($request->view_all) ? $request->view_all : 0;
            }

            $section_data = Content_Section::updateOrCreate(['id' => $requestData['id']], $requestData);
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

            Content_Section::where('id', $id)->delete();
            return response()->json(array('status' => 200, 'success' => __('Label.data_delete_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    // Sortable
    public function SectionSortable(Request $request)
    {
        try {

            $data = Content_Section::select('id', 'title')->where('section_type', 2)->where('is_home_screen', $request->is_home_screen)->where('top_category_id', $request->top_category_id)->orderBy('sortable', 'asc')->latest()->get();
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
                    Content_Section::where('id', $id_array[$i])->update(['sortable' => $i + 1]);
                }
            }

            return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
