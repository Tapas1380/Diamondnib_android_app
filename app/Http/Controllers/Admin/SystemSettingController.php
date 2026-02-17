<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Avatar;
use App\Models\Banner;
use App\Models\Bookmark;
use App\Models\Category;
use App\Models\Comment;
use App\Models\Common;
use App\Models\Content;
use App\Models\Content_Episode;
use App\Models\Content_Play;
use App\Models\Content_Section;
use App\Models\Follow;
use App\Models\History;
use App\Models\Language;
use App\Models\Like;
use App\Models\Music;
use App\Models\Music_Section;
use App\Models\Notification;
use App\Models\Package;
use App\Models\Page;
use App\Models\Read_Notification;
use App\Models\Reviews;
use App\Models\Reward_Transaction;
use App\Models\Threads;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet_Transaction;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\File;

class SystemSettingController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index()
    {
        try {

            $params['data'] = [];
            return view('admin.system_setting.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function ClearData()
    {
        try {

            // Folder Name
            $app = 'public/app';
            $avatar = 'public/avatar';
            $artist = 'public/artist';
            $category = 'public/category';
            $content = 'public/content';
            $database = 'public/database';
            $language = 'public/language';
            $music = 'public/music';
            $notification = 'public/notification';
            $package = 'public/package';
            $threads = 'public/threads';
            $user = 'public/user';

            // Name Array
            $app_name = [];
            $avatar_name = [];
            $artist_name = [];
            $category_name = [];
            $content_name = [];
            $database_name = [];
            $language_name = [];
            $music_name = [];
            $notification_name = [];
            $package_name = [];
            $threads_name = [];
            $user_name = [];

            // Get Files
            $app_file = Storage::allFiles($app);
            $avatar_file = Storage::allFiles($avatar);
            $artist_file = Storage::allFiles($artist);
            $category_file = Storage::allFiles($category);
            $content_file = Storage::allFiles($content);
            $database_file = Storage::allFiles($database);
            $language_file = Storage::allFiles($language);
            $music_file = Storage::allFiles($music);
            $notification_file = Storage::allFiles($notification);
            $package_file = Storage::allFiles($package);
            $threads_file = Storage::allFiles($threads);
            $user_file = Storage::allFiles($user);

            // Add Name In Array
            foreach ($app_file as $app_file) {
                array_push($app_name, pathinfo($app_file)['basename']);
            }
            foreach ($avatar_file as $avatar_file) {
                array_push($avatar_name, pathinfo($avatar_file)['basename']);
            }
            foreach ($artist_file as $artist_file) {
                array_push($artist_name, pathinfo($artist_file)['basename']);
            }
            foreach ($category_file as $file_name) {
                array_push($category_name, pathinfo($file_name)['basename']);
            }
            foreach ($content_file as $content_file) {
                array_push($content_name, pathinfo($content_file)['basename']);
            }
            foreach ($database_file as $database_file) {
                array_push($database_name, pathinfo($database_file)['basename']);
            }
            foreach ($language_file as $language_file) {
                array_push($language_name, pathinfo($language_file)['basename']);
            }
            foreach ($music_file as $music_file) {
                array_push($music_name, pathinfo($music_file)['basename']);
            }
            foreach ($notification_file as $notification_file) {
                array_push($notification_name, pathinfo($notification_file)['basename']);
            }
            foreach ($package_file as $package_file) {
                array_push($package_name, pathinfo($package_file)['basename']);
            }
            foreach ($threads_file as $threads_file) {
                array_push($threads_name, pathinfo($threads_file)['basename']);
            }
            foreach ($user_file as $user_file) {
                array_push($user_name, pathinfo($user_file)['basename']);
            }

            // Delete File In Folder
            foreach ($app_name as $key => $value) {

                $app_file_check = Page::select('id')->where('icon', $value)->first();

                $settingData = settingData();
                $app_file_check_2 = 'yes';
                if ($settingData['app_logo'] != $value) {
                    $app_file_check_2 = 'no';
                }

                if ($app_file_check == null && $app_file_check_2 == 'no') {
                    $this->common->deleteImageToFolder('app', $value);
                }
            }
            foreach ($avatar_name as $key => $value) {

                $avatar_file_check = Avatar::select('id')->where('image', $value)->first();
                if ($avatar_file_check == null) {
                    $this->common->deleteImageToFolder('avatar', $value);
                }
            }
            foreach ($artist_name as $key => $value) {

                $artist_file_check = Artist::select('id')->where('image', $value)->first();
                if ($artist_file_check == null) {
                    $this->common->deleteImageToFolder('artist', $value);
                }
            }
            foreach ($category_name as $key => $value) {

                $category_file_check = Category::select('id')->where('image', $value)->first();
                if ($category_file_check == null) {
                    $this->common->deleteImageToFolder('category', $value);
                }
            }
            foreach ($content_name as $key => $value) {

                $content_file_check = Content::select('id')->where('portrait_img', $value)->orwhere('landscape_img', $value)->orwhere('web_banner_img', $value)->orwhere('full_novel', $value)->first();
                $content_file_check_1 = Content_Episode::select('id')->where('image', $value)->orwhere('audio', $value)->orwhere('video', $value)->orwhere('book', $value)->first();

                if ($content_file_check == null && $content_file_check_1 == null) {
                    $this->common->deleteImageToFolder('content', $value);
                }
            }
            foreach ($database_name as $key => $value) {
                $this->common->deleteImageToFolder('database', $value);
            }
            foreach ($language_name as $key => $value) {

                $language_file_check = Language::select('id')->where('image', $value)->first();
                if ($language_file_check == null) {
                    $this->common->deleteImageToFolder('language', $value);
                }
            }
            foreach ($music_name as $key => $value) {

                $music_file_check = Music::select('id')->where('portrait_img', $value)->orwhere('landscape_img', $value)->orwhere('music', $value)->first();
                if ($music_file_check == null) {
                    $this->common->deleteImageToFolder('music', $value);
                }
            }
            foreach ($notification_name as $key => $value) {

                $notification_file_check = Notification::select('id')->where('image', $value)->first();
                if ($notification_file_check == null) {
                    $this->common->deleteImageToFolder('notification', $value);
                }
            }
            foreach ($package_name as $key => $value) {

                $package_file_check = Package::select('id')->where('image', $value)->first();
                if ($package_file_check == null) {
                    $this->common->deleteImageToFolder('package', $value);
                }
            }
            foreach ($threads_name as $key => $value) {

                $threads_file_check = Threads::select('id')->where('image', $value)->first();
                if ($threads_file_check == null) {
                    $this->common->deleteImageToFolder('threads', $value);
                }
            }
            foreach ($user_name as $key => $value) {

                $user_file_check = User::select('id')->where('image', $value)->first();
                if ($user_file_check == null) {
                    $this->common->deleteImageToFolder('user', $value);
                }
            }

            return response()->json(array('status' => 200, 'success' => 'Data Clear Successfully.'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function DownloadSqlFile()
    {
        try {

            Artisan::call('config:clear');

            $storageAt = storage_path() . "/app/public/database";
            if (!file_exists($storageAt)) {
                File::makeDirectory($storageAt, 0755, true, true);
            }

            $mysqlHostName = env('DB_HOST');
            $mysqlUserName = env('DB_USERNAME');
            $mysqlPassword = env('DB_PASSWORD');
            $DbName = env('DB_DATABASE');

            // get all table name
            $result = DB::select("SHOW TABLES");
            $prep = "Tables_in_$DbName";

            foreach ($result as $res) {
                $tables[] =  $res->$prep;
            }

            $connect = new \PDO("mysql:host=$mysqlHostName;dbname=$DbName;charset=utf8", "$mysqlUserName", "$mysqlPassword", array(\PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES 'utf8'"));
            $statement = $connect->prepare("SHOW TABLES");
            $statement->execute();
            $result = $statement->fetchAll();

            $output = '';
            foreach ($tables as $table) {

                $show_table_query = "SHOW CREATE TABLE " . $table . "";
                $statement = $connect->prepare($show_table_query);
                $statement->execute();
                $show_table_result = $statement->fetchAll();

                foreach ($show_table_result as $show_table_row) {
                    $output .= "\n\n" . $show_table_row["Create Table"] . ";\n\n";
                }
                $select_query = "SELECT * FROM " . $table . "";
                $statement = $connect->prepare($select_query);
                $statement->execute();
                $total_row = $statement->rowCount();

                for ($count = 0; $count < $total_row; $count++) {
                    $single_result = $statement->fetch(\PDO::FETCH_ASSOC);
                    $table_column_array = array_keys($single_result);
                    $table_value_array = array_values($single_result);
                    $output .= "\nINSERT INTO $table (";
                    $output .= "`" . implode("`, `", $table_column_array) . "`) VALUES (";
                    $output .= "'" . implode("', '", $table_value_array) . "');\n";
                }
            }

            $file_name = App_Name() . '_db_' . date('d_m_Y') . '.sql';
            $file_handle = fopen(storage_path() . '/app/public/database/' . $file_name, 'w+');
            fwrite($file_handle, $output);
            fclose($file_handle);
            header('Content-Description: File Transfer');
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename=' . basename($file_name));
            header('Content-Transfer-Encoding: binary');
            header('Expires: 0');
            header('Cache-Control: must-revalidate');
            header('Pragma: public');
            header('Content-Length: ' . filesize(storage_path() . '/app/public/database/' . $file_name));
            ob_clean();
            flush();
            readfile(storage_path() . '/app/public/database/' . $file_name);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function CleanDatabase()
    {
        try {

            Artist::query()->truncate();
            Avatar::query()->truncate();
            Banner::query()->truncate();
            Bookmark::query()->truncate();
            Category::query()->truncate();
            Comment::query()->truncate();
            Content::query()->truncate();
            Content_Episode::query()->truncate();
            Content_Play::query()->truncate();
            Content_Section::query()->truncate();
            Follow::query()->truncate();
            History::query()->truncate();
            Language::query()->truncate();
            Like::query()->truncate();
            Music::query()->truncate();
            Music_Section::query()->truncate();
            Notification::query()->truncate();
            Package::query()->truncate();
            Read_Notification::query()->truncate();
            Reviews::query()->truncate();
            Reward_Transaction::query()->truncate();
            Threads::query()->truncate();
            Transaction::query()->truncate();
            User::query()->truncate();
            Wallet_Transaction::query()->truncate();

            return response()->json(array('status' => 200, 'success' => 'Data Clean Successfully.'));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
