<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Page;
use App\Models\Common;
use App\Models\General_Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class PageController extends Controller
{
    private $folder_app = "app";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['data'] = [];
            $params['setting_data'] = settingData();

            if ($request->ajax()) {

                $input_search = $request['input_search'];

                if ($input_search != null && isset($input_search)) {
                    $data = Page::where('title', 'LIKE', "%{$input_search}%")->get();
                } else {
                    $data = Page::get();
                }

                $this->common->imageNameToUrl($data, 'icon', $this->folder_app);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $btn = '<div class="d-flex justify-content-around">';
                        $btn .= '<a href="' . route('page.edit', [$row->id]) . '" class="edit-delete-btn" title="Edit">';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= '<a href="' . route('admin.pages', [$row->page_name]) . '" class="edit-delete-btn" target="_blank" title="View">';
                        $btn .= '<i class="fa-regular fa-eye fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= '</div>';
                        return $btn;
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.page.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'background_color' => 'required',
                'title_color' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $data = $request->all();
            $data["page_background_color"] = isset($data['background_color']) ? $data['background_color'] : '';
            $data["page_title_color"] = isset($data['title_color']) ? $data['title_color'] : '';

            foreach ($data as $key => $value) {
                $setting = General_Setting::where('key', $key)->first();
                if (isset($setting->id)) {
                    $setting->value = $value;
                    $setting->save();
                }
            }
            return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit($id)
    {
        try {
            $params['data'] = Page::where('id', $id)->first();

            if ($params['data'] != null) {

                $params['settings'] = settingData();

                $this->common->imageNameToUrl(array($params['data']), 'icon', $this->folder_app);

                return view('admin.page.edit', $params);
            } else {
                return redirect()->back()->with('error', __('Label.page_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'title' => 'required',
                'description' => 'required',
                'icon' => 'image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $page = Page::where('id', $request->id)->first();
            if (isset($page->id)) {

                $page->title = $request->title;
                $page->description = $request->description;
                $page->status = 1;

                if (isset($request->icon)) {
                    $files = $request->icon;
                    $page->icon = $this->common->saveImage($files, $this->folder_app);

                    $this->common->deleteImageToFolder($this->folder_app, basename($request->old_icon));
                }

                if ($page->save()) {
                    return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
                } else {
                    return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
                }
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
