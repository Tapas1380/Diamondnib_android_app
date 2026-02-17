<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Mail;
use Exception;

class Common extends Model
{
    private $folder_content = "content";
    private $folder_music = "music";
    private $folder_artist = "artist";

    // Image Functions
    public function saveImage($org_name, $folder)
    {
        try {
            $img_ext = $org_name->getClientOriginalExtension();
            $filename = date('d_m_Y_') . rand(0, 99) . '_' . uniqid() . '.' . $img_ext;
            $path = $org_name->move(base_path('storage/app/public/' . $folder), $filename);
            return $filename;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function imageNameToUrl($array, $column, $folder)
    {
        try {

            foreach ($array as $key => $value) {

                $appName = Config::get('app.image_url');

                if (isset($value[$column]) && $value[$column] != "") {

                    if ($folder == "user" || $folder == "artist") {

                        if (Storage::disk('public')->exists($folder . '/' . $value[$column])) {
                            $value[$column] = $appName . $folder . '/' . $value[$column];
                        } else {
                            $value[$column] = asset('assets/imgs/default.png');
                        }
                    } else {

                        if (Storage::disk('public')->exists($folder . '/' . $value[$column])) {
                            $value[$column] = $appName . $folder . '/' . $value[$column];
                        } else {
                            $value[$column] = asset('assets/imgs/no_img.png');
                        }
                    }
                } else {
                    if ($folder == "user" || $folder == "artist") {
                        $value[$column] = asset('assets/imgs/default.png');
                    } else {
                        $value[$column] = asset('assets/imgs/no_img.png');
                    }
                }
            }
            return $array;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function deleteImageToFolder($folder, $name)
    {
        try {
            Storage::disk('public')->delete($folder . '/' . $name);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function videoNameToUrl($array, $column, $folder)
    {
        try {

            foreach ($array as $key => $value) {

                $appName = Config::get('app.image_url');

                if (isset($value[$column]) && $value[$column] != "") {

                    if (Storage::disk('public')->exists($folder . '/' . $value[$column])) {
                        $value[$column] = $appName . $folder . '/' . $value[$column];
                    } else {
                        $value[$column] = "";
                    }
                } else {
                    $value[$column] = "";
                }
            }
            return $array;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function getImage($folder = "", $name = "")
    {
        try {

            $appName = Config::get('app.image_url');

            if ($folder != "" && $name != "") {
                if ($folder == "user" || $folder == "artist") {

                    if (Storage::disk('public')->exists($folder . '/' . $name)) {
                        $name = $appName . $folder . '/' . $name;
                    } else {
                        $name = asset('assets/imgs/default.png');
                    }
                } else {

                    if (Storage::disk('public')->exists($folder . '/' . $name)) {
                        $name = $appName . $folder . '/' . $name;
                    } else {
                        $name = asset('assets/imgs/no_img.png');
                    }
                }
            } else {
                if ($folder == "user" || $folder == "artist") {
                    $name = asset('assets/imgs/default.png');
                } else {
                    $name = asset('assets/imgs/no_img.png');
                }
            }
            return $name;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function getWebImage($folder = "", $name = "")
    {
        try {

            $appName = Config::get('app.image_url');

            if ($folder != "" && $name != "") {

                if (Storage::disk('public')->exists($folder . '/' . $name)) {
                    $name = $appName . $folder . '/' . $name;
                } else {
                    $name = "";
                }
            } else {
                $name = "";
            }
            return $name;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function getBook($folder = "", $name = "")
    {
        try {

            $appName = Config::get('app.image_url');

            if ($folder != "" && $name != "") {

                if (Storage::disk('public')->exists($folder . '/' . $name)) {
                    $name = $appName . $folder . '/' . $name;
                } else {
                    $name = "";
                }
            } else {
                $name = "";
            }
            return $name;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    // API's Functions
    public function API_Response($status_code, $message, $array = [], $pagination = '')
    {
        try {
            $data['status'] = $status_code;
            $data['message'] = $message;

            if ($status_code == 200) {
                $data['result'] = $array;
            }

            if ($pagination) {
                $data['total_rows'] = $pagination['total_rows'];
                $data['total_page'] = $pagination['total_page'];
                $data['current_page'] = $pagination['current_page'];
                $data['more_page'] = $pagination['more_page'];
            }
            return $data;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function more_page($current_page, $page_size)
    {
        try {
            $more_page = false;
            if ($current_page < $page_size) {
                $more_page = true;
            }
            return $more_page;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function pagination_array($total_rows, $page_size, $current_page, $more_page)
    {
        try {
            $array['total_rows'] = $total_rows;
            $array['total_page'] = $page_size;
            $array['current_page'] = (int) $current_page;
            $array['more_page'] = $more_page;

            return $array;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function Pagination($data, $page_no)
    {
        try {
            $page_size = 0;
            $current_page = 0;
            $more_page = false;

            $total_rows = $data->count();
            $total_page = env('PAGE_LIMIT');
            $page_size = ceil($total_rows / $total_page);
            $current_page = $page_no ?? 1;
            $offset = $current_page * $total_page - $total_page;

            $more_page = $this->more_page($current_page, $page_size);
            $pagination = $this->pagination_array($total_rows, $page_size, $current_page, $more_page);

            $data->take($total_page)->offset($offset);
            $data = $data->get();

            $return['data'] = $data;
            $return['pagination'] = $pagination;
            return $return;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }

    // Common Functions
    public function user_name($string)
    {
        $rand_number = rand(0, 1000);
        $user_name = '@' . $string . '_' . $rand_number;

        $check = User::where('user_name', $user_name)->first();
        if (isset($check) && $check != null) {
            $this->user_name($string);
        }
        return $user_name;
    }
    public function artist_tag_line()
    {
        $line = "Hey, I am Artist on " . App_Name() . " App.";
        return $line;
    }
    public function user_tag_line()
    {
        $line = "Hey, I am User on " . App_Name() . " App.";
        return $line;
    }
    public function SetSmtpConfig()
    {
        $smtp = Smtp_Setting::latest()->first();
        if (isset($smtp) && $smtp != null && $smtp['status'] == 1) {

            if ($smtp) {
                $data = [
                    'driver' => 'smtp',
                    'host' => $smtp->host,
                    'port' => $smtp->port,
                    'encryption' => 'tls',
                    'username' => $smtp->user,
                    'password' => $smtp->pass,
                    'from' => [
                        'address' => $smtp->from_email,
                        'name' => $smtp->from_name
                    ]
                ];
                Config::set('mail', $data);
            }
        }
        return true;
    }
    public function Send_Mail($type, $email) // Type = 1- Register Mail, 2 Transaction Mail
    {
        try {

            $this->SetSmtpConfig();

            $smtp = Smtp_Setting::latest()->first();
            if (isset($smtp) && $smtp != false && $smtp['status'] == 1) {

                if ($type == 1) {
                    $title = App_Name() . " - Register";
                    $body = "Welcome to " . App_Name() . " App & Enjoy this app.";
                } else if ($type == 2) {
                    $title = App_Name() . " - Transaction";
                    $body = "Welcome to " . App_Name() . " App & Enjoy this app. You have Successfully Transaction.";
                } else {
                    return true;
                }
                $details = [
                    'title' => $title,
                    'body' => $body
                ];

                // Send Mail
                try {
                    Mail::to($email)->send(new \App\Mail\mail($details));
                    return true;
                } catch (\Swift_TransportException $e) {
                    return true;
                }
            } else {
                return true;
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function content_section_query($user_id, $content_type, $category_id, $language_id, $artist_id, $order_by_play, $order_by_upload, $no_of_content)
    {
        try {

            // Remove Not Episode
            if ($content_type == 1 || $content_type == 2) {

                $episode = Content_Episode::select('content_id')->where('status', 1)->groupBy('content_id')->get();
                $content_id = [];
                for ($i = 0; $i < count($episode); $i++) {
                    $content_id[$i] = $episode[$i]['content_id'];
                }

                $content = Content::whereIn('id', $content_id)->where('content_type', $content_type)->where('status', 1);
            } else {
                $content = Content::where('content_type', $content_type)->where('status', 1);
            }

            if ($category_id != 0) {
                $content->where('category_id', $category_id);
            }
            if ($language_id != 0) {
                $content->where('language_id', $language_id);
            }
            if ($artist_id != 0) {
                $content->where('artist_id', $artist_id);
            }
            if ($order_by_play == 2) {
                $content->orderBy('total_played', 'desc');
            }
            if ($order_by_upload == 2) {
                $content->orderBy('id', 'desc');
            }
            $query = $content->take($no_of_content)->get();

            for ($j = 0; $j < count($query); $j++) {

                $query[$j]['portrait_img'] = $this->getImage($this->folder_content, $query[$j]['portrait_img']);
                $query[$j]['landscape_img'] = $this->getImage($this->folder_content, $query[$j]['landscape_img']);
                $query[$j]['web_banner_img'] = $this->getWebImage($this->folder_content, $query[$j]['web_banner_img']);
                $query[$j]['full_novel'] = $this->getBook($this->folder_content, $query[$j]['full_novel']);
                $query[$j]['category_name'] = $this->getCategoryName($query[$j]['category_id']);
                $query[$j]['artist_name'] = $this->getArtistName($query[$j]['artist_id']);
                $query[$j]['language_name'] = $this->getLanguageName($query[$j]['language_id']);
                $query[$j]['avg_rating'] = $this->getAvgRating($query[$j]['content_type'], $query[$j]['id']);
                $query[$j]['total_episode'] = $this->getTotalEpisode($query[$j]['id']);
                $query[$j]['total_reviews'] = $this->getTotalReviews($query[$j]['id']);
                $query[$j]['total_user_play'] = $this->getTotalPlay($query[$j]['content_type'], $query[$j]['id']);
                $query[$j]['is_bookmark'] = $this->isBookmark($user_id, $query[$j]['content_type'], $query[$j]['id']);
            }

            return $query;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function content_section_details_query($user_id, $content_type, $category_id, $language_id, $artist_id, $order_by_play, $order_by_upload)
    {
        try {

            // Remove Not Episode
            if ($content_type == 1 || $content_type == 2) {

                $episode = Content_Episode::select('content_id')->where('status', 1)->groupBy('content_id')->get();
                $content_id = [];
                for ($i = 0; $i < count($episode); $i++) {
                    $content_id[$i] = $episode[$i]['content_id'];
                }

                $content = Content::whereIn('id', $content_id)->where('content_type', $content_type)->where('status', 1);
            } else {
                $content = Content::where('content_type', $content_type)->where('status', 1);
            }

            if ($category_id != 0) {
                $content->where('category_id', $category_id);
            }
            if ($language_id != 0) {
                $content->where('language_id', $language_id);
            }
            if ($artist_id != 0) {
                $content->where('artist_id', $artist_id);
            }
            if ($order_by_play == 2) {
                $content->orderBy('total_played', 'desc');
            }
            if ($order_by_upload == 2) {
                $content->orderBy('id', 'desc');
            }
            $query = $content;

            return $query;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function getCategoryName($category_id)
    {
        $category_name = "";
        $category = Category::where('id', $category_id)->first();
        if ($category != null & isset($category)) {
            $category_name = $category['name'];
        }
        return $category_name;
    }
    public function getArtistName($artist_id)
    {
        $artist_name = "";
        $artist = Artist::where('id', $artist_id)->first();
        if ($artist != null & isset($artist)) {
            $artist_name = $artist['user_name'];
        }
        return $artist_name;
    }
    public function getArtistImage($artist_id)
    {
        $artist_image = asset('assets/imgs/default.png');
        $artist = Artist::where('id', $artist_id)->first();
        if (isset($artist) && $artist != null) {
            $artist['image'] = $this->getImage($this->folder_artist, $artist['image']);
            return $artist['image'];
        }
    }
    public function getArtistFollowers($artist_id)
    {
        $artist_follower = Follow::where('artist_id', $artist_id)->where('status', 1)->count();
        return $artist_follower;
    }
    public function getLanguageName($language_id)
    {
        $language_name = "";
        $language = Language::where('id', $language_id)->first();
        if ($language != null & isset($language)) {
            $language_name = $language['name'];
        }
        return $language_name;
    }
    public function getTotalEpisode($content_id)
    {
        $total_episode = Content_Episode::where('content_id', $content_id)->where('status', 1)->count();
        return $total_episode;
    }
    public function getTotalReviews($content_id)
    {
        $total_reviews = Reviews::where('content_id', $content_id)->where('status', 1)->count();
        return $total_reviews;
    }
    public function getAvgRating($content_type, $content_id)
    {
        $avg_rating = "0.0";
        $rating = Reviews::where('content_type', $content_type)->where('content_id', $content_id)->avg('rating');
        if (isset($rating) && $rating != null) {
            $avg_rating = $rating;
        }
        return number_format($avg_rating, 1);
    }
    public function isFollow($user_id, $artist_id)
    {
        $follow = Follow::where('artist_id', $artist_id)->where('user_id', $user_id)->where('status', 1)->first();
        if (!empty($follow)) {
            return 1;
        } else {
            return 0;
        }
    }
    public function stopTime($content_type, $audiobook_type, $user_id, $content_id, $content_episode_id)
    {
        $stop_time = History::where('content_type', $content_type)->where('audiobook_type', $audiobook_type)->where('user_id', $user_id)->where('content_id', $content_id)->where('content_episode_id', $content_episode_id)->where('status', 1)->latest()->first();
        if (isset($stop_time) && $stop_time != null) {
            return (int)$stop_time['stop_time'];
        } else {
            return 0;
        }
    }
    public function isBuy($content_type, $audiobook_type, $user_id, $content_id, $content_episode_id)
    {
        $data = Wallet_Transaction::where('content_type', $content_type)->where('audiobook_type', $audiobook_type)->where('user_id', $user_id)->where('content_id', $content_id)->where('content_episode_id', $content_episode_id)->where('status', 1)->latest()->first();
        if (isset($data) && $data != null) {
            return 1;
        } else {
            return 0;
        }
    }
    public function music_section_query($user_id, $category_id, $language_id, $artist_id, $order_by_play, $order_by_upload, $no_of_content)
    {
        try {

            $content = Music::where('status', 1);

            if ($category_id != 0) {
                $content->where('category_id', $category_id);
            }
            if ($language_id != 0) {
                $content->where('language_id', $language_id);
            }
            if ($artist_id != 0) {
                $content->where('artist_id', $artist_id);
            }
            if ($order_by_play == 2) {
                $content->orderBy('total_played', 'desc');
            }
            if ($order_by_upload == 2) {
                $content->orderBy('id', 'desc');
            }
            $query = $content->take($no_of_content)->get();

            for ($j = 0; $j < count($query); $j++) {

                $query[$j]['portrait_img'] = $this->getImage($this->folder_music, $query[$j]['portrait_img']);
                $query[$j]['landscape_img'] = $this->getImage($this->folder_music, $query[$j]['landscape_img']);
                $query[$j]['web_banner_img'] = $this->getWebImage($this->folder_content, $query[$j]['web_banner_img']);
                if ($query[$j]['music_upload_type'] == 'server_video') {
                    $query[$j]['music'] = $this->getBook($this->folder_music, $query[$j]['music']);
                }
                $query[$j]['category_name'] = $this->getCategoryName($query[$j]['category_id']);
                $query[$j]['artist_name'] = $this->getArtistName($query[$j]['artist_id']);
                $query[$j]['language_name'] = $this->getLanguageName($query[$j]['language_id']);
                $query[$j]['content_type'] = 3;
            }

            return $query;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function music_section_details_query($user_id, $category_id, $language_id, $artist_id, $order_by_play, $order_by_upload)
    {
        try {

            $content = Music::where('status', 1);

            if ($category_id != 0) {
                $content->where('category_id', $category_id);
            }
            if ($language_id != 0) {
                $content->where('language_id', $language_id);
            }
            if ($artist_id != 0) {
                $content->where('artist_id', $artist_id);
            }
            if ($order_by_play == 2) {
                $content->orderBy('total_played', 'desc');
            }
            if ($order_by_upload == 2) {
                $content->orderBy('id', 'desc');
            }
            $query = $content;

            return $query;
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function getArtistFollow($user_id)
    {
        $data = Follow::where('user_id', $user_id)->where('status', 1)->with('artist')->get();

        $artist_ids = array();
        foreach ($data as $key => $value) {

            if ($value['artist'] != null && isset($value['artist'])) {
                $artist_ids[] = $value['artist']['id'];
            }
        }
        return $artist_ids;
    }
    public function getTotalComment($threads_id)
    {
        $total_comment = Comment::where('comment_id', 0)->where('threads_id', $threads_id)->where('status', 1)->count();
        return $total_comment;
    }
    public function sendNotification($array)
    {
        // Send via Firebase FCM V1 API (Current)
        $this->sendFCMNotificationV1($array);
        
        // Also send via OneSignal (if you want to keep it as backup)
        // $this->sendOneSignalNotification($array);
    }

    /**
     * Send Push Notification via Firebase Cloud Messaging V1 API
     * Uses Service Account JSON for OAuth2 authentication
     */
    public function sendFCMNotificationV1($array)
    {
        try {
            // Path to your service account JSON file
            // Upload this file to your server (outside public folder for security)
            $serviceAccountPath = base_path('firebase-service-account.json');
            
            // Your Firebase Project ID
            $projectId = 'diamondnib';
            
            // Get OAuth2 Access Token
            $accessToken = $this->getFirebaseAccessToken($serviceAccountPath);
            
            if (!$accessToken) {
                \Log::error('FCM V1: Failed to get access token');
                return false;
            }
            
            // FCM V1 API URL
            $url = 'https://fcm.googleapis.com/v1/projects/' . $projectId . '/messages:send';
            
            // Build the message payload for V1 API
            $message = array(
                'message' => array(
                    'topic' => 'all_users',
                    'notification' => array(
                        'title' => $array['title'] ?? 'New Content Available!',
                        'body' => $array['description'] ?? 'Check out the latest content on DiamondNib',
                        'image' => $array['image'] ?? '',
                    ),
                    'data' => array(
                        'id' => (string)($array['id'] ?? ''),
                        'title' => $array['title'] ?? '',
                        'image' => $array['image'] ?? '',
                        'content_type' => (string)($array['content_type'] ?? '1'),
                        'description' => $array['description'] ?? '',
                        'type' => 'new_content',
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ),
                    'android' => array(
                        'priority' => 'high',
                        'notification' => array(
                            'channel_id' => 'high_importance_channel',
                            'sound' => 'default',
                            'default_sound' => true,
                            'default_vibrate_timings' => true,
                        ),
                    ),
                    'apns' => array(
                        'payload' => array(
                            'aps' => array(
                                'sound' => 'default',
                                'badge' => 1,
                            ),
                        ),
                    ),
                ),
            );
            
            $headers = array(
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json',
            );
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($message));
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);
            
            // Log the response
            \Log::info('FCM V1 Response [' . $httpCode . ']: ' . $response);
            
            if ($error) {
                \Log::error('FCM V1 cURL Error: ' . $error);
                return false;
            }
            
            return ($httpCode == 200);
            
        } catch (Exception $e) {
            \Log::error('FCM V1 Exception: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Get Firebase OAuth2 Access Token from Service Account JSON
     */
    private function getFirebaseAccessToken($serviceAccountPath)
    {
        try {
            if (!file_exists($serviceAccountPath)) {
                \Log::error('FCM: Service account file not found at: ' . $serviceAccountPath);
                return null;
            }
            
            $serviceAccount = json_decode(file_get_contents($serviceAccountPath), true);
            
            if (!$serviceAccount) {
                \Log::error('FCM: Invalid service account JSON');
                return null;
            }
            
            // Create JWT Header
            $header = array(
                'alg' => 'RS256',
                'typ' => 'JWT',
            );
            
            // Create JWT Claim Set
            $now = time();
            $claim = array(
                'iss' => $serviceAccount['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600, // Token expires in 1 hour
            );
            
            // Encode Header and Claim
            $base64Header = $this->base64UrlEncode(json_encode($header));
            $base64Claim = $this->base64UrlEncode(json_encode($claim));
            
            // Create Signature
            $signatureInput = $base64Header . '.' . $base64Claim;
            $privateKey = $serviceAccount['private_key'];
            
            openssl_sign($signatureInput, $signature, $privateKey, 'SHA256');
            $base64Signature = $this->base64UrlEncode($signature);
            
            // Create JWT
            $jwt = $signatureInput . '.' . $base64Signature;
            
            // Exchange JWT for Access Token
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query(array(
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            )));
            
            $response = curl_exec($ch);
            $error = curl_error($ch);
            curl_close($ch);
            
            if ($error) {
                \Log::error('FCM OAuth Error: ' . $error);
                return null;
            }
            
            $data = json_decode($response, true);
            
            if (isset($data['access_token'])) {
                return $data['access_token'];
            }
            
            \Log::error('FCM OAuth Response Error: ' . $response);
            return null;
            
        } catch (Exception $e) {
            \Log::error('FCM getAccessToken Exception: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Base64 URL Encode (for JWT)
     */
    private function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Send Push Notification via OneSignal (Backup/Legacy)
     */
    public function sendOneSignalNotification($array)
    {
        $settingData = settingData();
        $ONESIGNAL_APP_ID = $settingData['onesignal_apid'];
        $ONESIGNAL_REST_KEY = $settingData['onesignal_rest_key'];

        $fields = array(
            'app_id' => $ONESIGNAL_APP_ID,
            'included_segments' => array('All'),
            'data' => $array,
            'headings' => array("en" => $array['title']),
            'contents' => array("en" => $array['description']),
            'big_picture' => $array['image'],
        );
        $fields = json_encode($fields);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'Content-Type: application/json; charset=utf-8',
            'Authorization: Basic ' . $ONESIGNAL_REST_KEY,
        ));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        $response = curl_exec($ch);
        curl_close($ch);
    }
    public function isLikeThreads($user_id, $threads_id)
    {
        $data = Like::where('user_id', $user_id)->where('threads_id', $threads_id)->where('status', 1)->latest()->first();
        if (isset($data) && $data != null) {
            return 1;
        } else {
            return 0;
        }
    }
    public function getTotalPlay($content_type, $content_id)
    {
        $total = 0;
        if ($content_type == 1) {

            $total_play = Content_Episode::where('content_id', $content_id)->where('status', 1)->sum('total_audio_played');
            return (int) $total_play;
        } else if ($content_type == 2) {
            $total_play = Content_Episode::where('content_id', $content_id)->where('status', 1)->sum('total_book_played');
            return (int) $total_play;
        } else {
            return (int) $total;
        }
    }
    public function isBookmark($user_id, $content_type, $content_id)
    {
        $check = Bookmark::where('user_id', $user_id)->where('content_type', $content_type)->where('content_id', $content_id)->where('status', 1)->first();
        if ($check != null && isset($check)) {
            $is_bookmark = 1;
        } else {
            $is_bookmark = 0;
        }
        return $is_bookmark;
    }
    public function setEnvironmentValue($envKey, $envValue)
    {
        $envFile = app()->environmentFilePath();
        $str = file_get_contents($envFile);

        $oldValue = env($envKey);

        if (strpos($str, $envKey) !== false) {
            $str = str_replace("{$envKey}={$oldValue}", "{$envKey}={$envValue}", $str);
        } else {
            $str .= "{$envKey}={$envValue}\n";
        }

        $fp = fopen($envFile, 'w');
        fwrite($fp, $str);
        fclose($fp);
        return $envValue;
    }
}
