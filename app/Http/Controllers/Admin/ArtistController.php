<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Common;
use App\Models\Follow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;

class ArtistController extends Controller
{
    private $folder = "artist";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {
            $params['data'] = [];
            if ($request->ajax()) {

                $input_search = $request['input_search'];

                if ($input_search != null && isset($input_search)) {
                    $data = Artist::where('user_name', 'LIKE', "%{$input_search}%")->latest()->get();
                } else {
                    $data = Artist::latest()->get();
                }

                $this->common->imageNameToUrl($data, 'image', $this->folder);

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $delete = ' <form onsubmit="return confirm(\'Are you sure !!! You want to Delete this Artist ?\');" method="POST"  action="' . route('artist.destroy', [$row->id]) . '">
                                <input type="hidden" name="_token" value="' . csrf_token() . '">
                                <input type="hidden" name="_method" value="DELETE">
                                <button type="submit" class="edit-delete-btn" style="outline: none;" title="Delete"><i class="fa-solid fa-trash-can fa-xl"></i></button></form>';

                        $btn = '<div class="d-flex justify-content-around">';
                        $btn .= '<a class="edit-delete-btn edit_artist" title="Edit" data-toggle="modal" href="#EditModel" data-id="' . $row->id . '" data-user_name="' . $row->user_name . '" data-image="' . $row->image . '" data-bio="' . $row->bio . '" data-instagram_url="' . $row->instagram_url . '" data-facebook_url="' . $row->facebook_url . '">';
                        $btn .= '<i class="fa-solid fa-pen-to-square fa-xl"></i>';
                        $btn .= '</a>';
                        $btn .= $delete;
                        $btn .= '</a></div>';
                        return $btn;
                    })
                    ->make(true);
            }
            return view('admin.artist.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_name' => 'required|min:2|unique:tbl_artist,user_name',
                'password' => 'required|min:4',
                'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();

            $requestData['password'] = Hash::make($requestData['password']);
            $files = $requestData['image'];
            $requestData['image'] = $this->common->saveImage($files, $this->folder);
            $requestData['bio'] = isset($request->bio) ? $request->bio : $this->common->artist_tag_line();
            $requestData['instagram_url'] = isset($request->instagram_url) ? $request->instagram_url : '';
            $requestData['facebook_url'] = isset($request->facebook_url) ? $request->facebook_url : '';
            $requestData['status'] = 1;

            $artist = Artist::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($artist->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update($id, Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_name' => 'required|min:2|unique:tbl_artist,user_name,' . $id,
                'image' => 'image|mimes:jpeg,png,jpg|max:2048',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $requestData = $request->all();

            $requestData['bio'] = isset($request->bio) ? $request->bio : '';
            $requestData['instagram_url'] = isset($request->instagram_url) ? $request->instagram_url : '';
            $requestData['facebook_url'] = isset($request->facebook_url) ? $request->facebook_url : '';
            if (isset($requestData['image'])) {
                $files = $requestData['image'];
                $requestData['image'] = $this->common->saveImage($files, $this->folder);

                $this->common->deleteImageToFolder($this->folder, basename($requestData['old_image']));
            }
            unset($requestData['old_image']);

            $artist_data = Artist::updateOrCreate(['id' => $requestData['id']], $requestData);
            if (isset($artist_data->id)) {
                return response()->json(array('status' => 200, 'success' => __('Label.data_edit_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.data_not_updated')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function destroy($id)
    {
        try {
            $data = Artist::where('id', $id)->first();
            if (isset($data)) {
                $this->common->deleteImageToFolder($this->folder, $data['image']);
                $data->delete();

                Follow::where('artist_id', $id)->delete();
            }
            return redirect()->route('artist.index')->with('success', __('Label.data_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
