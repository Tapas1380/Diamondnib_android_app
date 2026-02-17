<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Comment;
use App\Models\Common;
use App\Models\Like;
use App\Models\Threads;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Pagination\LengthAwarePaginator;
use Exception;

class ThreadsController extends Controller
{
    private $folder_threads = "threads";
    private $folder_user = "user";
    private $folder_artist = "artist";
    public $common;
    public $page_limit;
    public function __construct()
    {
        try {
            $this->common = new Common();
            $this->page_limit = env('PAGE_LIMIT');
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    public function get_threads_list(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'numeric',
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = isset($request->user_id) ? $request->user_id : 0;

            $page_no = $request->page_no ?? 1;
            $more_page = false;

            if ($user_id != 0) {

                $get_artist_follow = $this->common->getArtistFollow($user_id);
                $now = date("Y-m-d H:i:s");
                $last_24_hours = date("Y-m-d H:i:s", strtotime('-24 hours', strtotime($now)));

                // Get Recent Follow Artist Threads
                $recent_threads = Threads::where('user_type', 2)->whereIn('user_id', $get_artist_follow)->where('created_at', ">", $last_24_hours)->where('status', 1)->latest()->get()->toArray();
                $recent_threads_ids = array();
                foreach ($recent_threads as $key => $value) {
                    $recent_threads_ids[] = $value['id'];
                }

                // Get Recent All Threads
                $recent_all_threads = Threads::whereNotIn('id', $recent_threads_ids)->where('created_at', ">", $last_24_hours)->where('status', 1)->latest()->get()->toArray();
                $recent_all_threads_ids = array();
                foreach ($recent_all_threads as $key => $value) {
                    $recent_all_threads_ids[] = $value['id'];
                }

                // Get Other Threads
                $otherthreads = Threads::whereNotIn('id', $recent_threads_ids)->whereNotIn('id', $recent_all_threads_ids)->where('status', 1)->orderBy('id', 'desc')->latest()->get()->toArray();

                // Marge All Array 
                $final_array = array_merge($recent_threads, $recent_all_threads, $otherthreads);
            } else {

                $final_array = Threads::where('status', 1)->orderBy('id', 'desc')->latest()->get()->toArray();
            }

            // Pagination
            $currentItems = array_slice($final_array, $this->page_limit * ($page_no - 1), $this->page_limit);
            $paginator = new LengthAwarePaginator($currentItems, count($final_array), $this->page_limit, $page_no);

            $more_page = $this->common->more_page($page_no, $paginator->lastPage());
            $pagination = $this->common->pagination_array($paginator->total(), $paginator->lastPage(), $page_no, $more_page);

            $data = $paginator->items();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['image'] = $this->common->getImage($this->folder_threads, $data[$i]['image']);

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['user_image'] = "";
                    $data[$i]['is_artist'] = 0;
                    if ($data[$i]['user_type'] == 1) {

                        $data[$i]['is_artist'] = 1;
                        $user_data = User::where('id', $data[$i]['user_id'])->latest()->first();
                        if (isset($user_data) && $user_data != null) {

                            $data[$i]['user_name'] = $user_data['user_name'];
                            $data[$i]['full_name'] = $user_data['full_name'];
                            $data[$i]['user_image'] = $this->common->getImage($this->folder_user, $user_data['image']);
                        }
                    } else if ($data[$i]['user_type'] == 2) {

                        $data[$i]['is_artist'] = 2;
                        $user_data = Artist::where('id', $data[$i]['user_id'])->latest()->first();
                        if (isset($user_data) && $user_data != null) {

                            $data[$i]['user_name'] = $user_data['user_name'];
                            $data[$i]['full_name'] = $user_data['user_name'];
                            $data[$i]['user_image'] = $this->common->getImage($this->folder_artist, $user_data['image']);
                        }
                    }
                    $data[$i]['total_comment'] = $this->common->getTotalComment($data[$i]['id']);
                    $data[$i]['is_like'] = $this->common->isLikeThreads($user_id, $data[$i]['id']);

                    $data[$i]['images'] = [];
                    $like_user = Like::where('threads_id', $data[$i]['id'])->where('status', 1)->with('user')->orderBy('id', 'desc')->get();
                    if (isset($like_user) && $like_user != null) {
                        $count = 1;
                        for ($j = 0; $j < count($like_user); $j++) {

                            if ($like_user[$j]['user'] != null && isset($like_user[$j]['user'])) {
                                $data[$i]['images'][] = $this->common->getImage($this->folder_user, $like_user[$j]['user']['image']);
                                $count = $count + 1;
                            }

                            if ($count == 4) {
                                break;
                            }
                        }
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_remove_like_dislike(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'threads_id' => 'required',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'threads_id.required' => __('api_msg.threads_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $threads_id = $request['threads_id'];

            $like = Like::where('user_id', $user_id)->where('threads_id', $threads_id)->where('status', 1)->first();
            if (isset($like['id']) && $like != null) {

                Like::where('id', $like['id'])->delete();
                Threads::where('id', $threads_id)->decrement('total_like', 1);
                return $this->common->API_Response(200, __('api_msg.remove_successfully'));
            } else {

                $insert['user_id'] = $user_id;
                $insert['threads_id'] = $threads_id;
                $insert['status'] = 1;
                Like::insertGetId($insert);
                Threads::where('id', $threads_id)->increment('total_like', 1);
                return $this->common->API_Response(200, __('api_msg.add_successfully'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function add_comment(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'threads_id' => 'required|numeric',
                    'comment_id' => 'numeric',
                    'comment' => 'required',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'threads_id.required' => __('api_msg.threads_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $threads_id = $request['threads_id'];
            $comment_id = isset($request->comment_id) ? $request->comment_id : 0;
            $comment = $request['comment'];

            $insert = new Comment();
            $insert['comment_id'] = $comment_id;
            $insert['user_id'] = $user_id;
            $insert['threads_id'] = $threads_id;
            $insert['comment'] = $comment;
            $insert->save();

            return $this->common->API_Response(200, __('api_msg.comment_add_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit_comment(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'user_id' => 'required|numeric',
                    'comment_id' => 'required|numeric',
                    'comment' => 'required',
                ],
                [
                    'user_id.required' => __('api_msg.user_id_is_required'),
                    'comment.required' => __('api_msg.comment_is_required'),
                    'comment_id.required' => __('api_msg.comment_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $user_id = $request['user_id'];
            $comment_id = $request['comment_id'];
            $comment = $request['comment'];

            $update = Comment::where('id', $comment_id)->first();
            if (isset($update) && $update != null) {

                $update['user_id'] = $user_id;
                $update['id'] = $comment_id;
                $update['comment'] = $comment;
                $update->save();
                return $this->common->API_Response(200, __('api_msg.comment_edit_successfully'));
            }
            return $this->common->API_Response(200, __('api_msg.comment_not_found'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function delete_comment(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'comment_id' => 'required|numeric',
                ],
                [
                    'comment_id.required' => __('api_msg.comment_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $comment_id = $request['comment_id'];
            Comment::where('id', $comment_id)->delete();
            return $this->common->API_Response(200, __('api_msg.comment_delete_successfully'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_comment(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'threads_id' => 'required|numeric',
                ],
                [
                    'threads_id.required' => __('api_msg.threads_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $threads_id = $request['threads_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Comment::where('comment_id', 0)->where('threads_id', $threads_id)->where('status', 1)->orderBy('id', 'desc')->with('user');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['image'] = "";
                    if ($data[$i]['user'] != null) {
                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
                    }
                    unset($data[$i]['user']);

                    $data[$i]['is_reply'] = 0;
                    $data[$i]['total_reply'] = 0;
                    $reply = Comment::where('comment_id', $data[$i]['id'])->count();
                    if ($reply != 0) {
                        $data[$i]['is_reply'] = 1;
                        $data[$i]['total_reply'] = $reply;
                    }
                }
                return $this->common->API_Response(200, __('api_msg.get_record_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function get_reply_comment(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'comment_id' => 'required|numeric',
                ],
                [
                    'comment_id.required' => __('api_msg.comment_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $comment_id = $request['comment_id'];

            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $data = Comment::where('comment_id', $comment_id)->where('status', 1)->orderBy('id', 'desc')->with('user');

            $total_rows = $data->count();
            $total_page = $this->page_limit;
            $page_size = ceil($total_rows / $total_page);
            $current_page = $request->page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->common->more_page($current_page, $page_size);
            $pagination = $this->common->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->latest()->get();

            if (count($data) > 0) {

                for ($i = 0; $i < count($data); $i++) {

                    $data[$i]['user_name'] = "";
                    $data[$i]['full_name'] = "";
                    $data[$i]['image'] = "";
                    if ($data[$i]['user'] != null) {
                        $data[$i]['user_name'] = $data[$i]['user']['user_name'];
                        $data[$i]['full_name'] = $data[$i]['user']['full_name'];
                        $data[$i]['image'] = $this->common->getImage($this->folder_user, $data[$i]['user']['image']);
                    }
                    unset($data[$i]['user']);

                    $data[$i]['is_reply'] = 0;
                    $data[$i]['total_reply'] = 0;
                    $reply = Comment::where('comment_id', $data[$i]['id'])->count();
                    if ($reply != 0) {
                        $data[$i]['is_reply'] = 1;
                        $data[$i]['total_reply'] = $reply;
                    }
                }
                return $this->common->API_Response(200, __('api_msg.comment_add_successfully'), $data, $pagination);
            } else {
                return $this->common->API_Response(400, __('api_msg.data_not_found'));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function upload_threads(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'user_id' => 'required|numeric',
                'description' => 'required',
                'image' => 'required|image|mimes:jpeg,png,jpg|max:20480',
            ]);
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $insert = new Threads();
            $insert['user_type'] = 1;
            $insert['user_id'] = $request['user_id'];
            $insert['description'] = $request['description'];
            $files = $request['image'];
            $insert['image'] = $this->common->saveImage($files, $this->folder_threads);
            $insert['total_like'] = 0;
            $insert['status'] = 1;
            if ($insert->save()) {
                return response()->json(array('status' => 200, 'success' => __('api_msg.data_add_successfully')));
            } else {
                return response()->json(array('status' => 400, 'errors' => __('api_msg.data_not_added')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function delete_threads(Request $request)
    {
        try {
            $validation = Validator::make(
                $request->all(),
                [
                    'threads_id' => 'required|numeric',
                ],
                [
                    'threads_id.required' => __('api_msg.threads_id_is_required'),
                ]
            );
            if ($validation->fails()) {
                $data['status'] = 400;
                $data['message'] = $validation->errors()->first();
                return $data;
            }

            $delete_data = Threads::where('id', $request['threads_id'])->latest()->first();
            if ($delete_data != null && isset($delete_data)) {

                $this->common->deleteImageToFolder($this->folder_threads, $delete_data['image']);
                $delete_data->delete();

                Like::where('threads_id', $delete_data['id'])->delete();
                Comment::where('threads_id', $delete_data['id'])->delete();
            }

            return response()->json(array('status' => 200, 'success' => __('api_msg.content_delete_successfully')));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
