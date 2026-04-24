<?php

namespace App\Http\Controllers\Artist;

use App\Http\Controllers\Controller;
use App\Models\Content;
use App\Models\Reviews;
use App\Models\User;
use Illuminate\Http\Request;
use Exception;

class ReviewsController extends Controller
{
    public function index(Request $request)
    {
        try {
            $artist = Artist_Data();
            $params['data'] = [];
            $params['user'] = User::latest()->get();
            $params['content'] = Content::where('artist_id', $artist['id'])->latest()->get();

            if ($request->ajax()) {

                $input_search = $request['input_search'];
                $input_user = $request['input_user'];
                $input_content = $request['input_content'];

                $content_ids = [];
                for ($i = 0; $i < count($params['content']); $i++) {
                    $content_ids[] = $params['content'][$i]['id'];
                }

                if ($input_search != null && isset($input_search)) {

                    if ($input_user != 0 && $input_content == 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('comment', 'LIKE', "%{$input_search}%")->where('user_id', $input_user)->with('user', 'content')->latest()->get();
                    } else if ($input_user == 0 && $input_content != 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('comment', 'LIKE', "%{$input_search}%")->where('content_id', $input_content)->with('user', 'content')->latest()->get();
                    } else if ($input_user != 0 && $input_content != 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('comment', 'LIKE', "%{$input_search}%")->where('user_id', $input_user)
                            ->where('content_id', $input_content)->with('user', 'content')->latest()->get();
                    } else {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('comment', 'LIKE', "%{$input_search}%")->with('user', 'content')->latest()->get();
                    }
                } else {

                    if ($input_user != 0 && $input_content == 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('user_id', $input_user)->with('user', 'content')->latest()->get();
                    } else if ($input_user == 0 && $input_content != 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('content_id', $input_content)->with('user', 'content')->latest()->get();
                    } else if ($input_user != 0 && $input_content != 0) {
                        $data = Reviews::whereIn('content_id', $content_ids)->where('user_id', $input_user)->where('content_id', $input_content)->with('user', 'content')->latest()->get();
                    } else {
                        $data = Reviews::whereIn('content_id', $content_ids)->with('user', 'content')->latest()->get();
                    }
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        if ($row->status == 1) {
                            return "<button type='button' id='$row->id' onclick='change_status($row->id, $row->status)' style='background:#4e45b8; font-weight:bold; border: none; color: white; padding: 5px 15px; outline: none;border-radius: 5px;cursor: pointer;'>Show</button>";
                        } else {
                            return "<button type='button' id='$row->id' onclick='change_status($row->id, $row->status)' style='background:#4e45b8; font-weight:bold; border: none; color: white; padding: 5px 20px; outline: none;border-radius: 5px;cursor: pointer;'>Hide</button>";
                        }
                    })
                    ->addColumn('date', function ($row) {
                        $date = date("d-m-Y", strtotime($row->created_at));
                        return $date;
                    })
                    ->make(true);
            }
            return view('artist.reviews.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
