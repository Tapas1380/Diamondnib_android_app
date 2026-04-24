<?php

namespace App\Http\Controllers\Install;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schema;

class InstallController extends Controller
{
    public $common;
    public function __construct()
    {
        $this->common = new Common();
    }

    // Step 0
    public function step0(Request $request)
    {
        $url = $request->url();
        if (strpos($request->url(), '/public') === false) {
            return redirect($url . '/public');
        }

        Artisan::call('config:clear');
        
        $verflyDomain = Demo_Domain();
        if ($verflyDomain == 1) {

            return redirect()->route('admin.login');
        } else {

            try {

                // DB Check
                DB::connection()->getPdo();

                $pc = env(base64_decode('UFVSQ0hBU0VfQ09ERQ=='));
                $un = env(base64_decode('QlVZRVJfVVNFUk5BTUU='));
                $status = env(base64_decode('UFVSQ0hBU0VfU1RBVFVT'));

                if (!empty($pc) && !empty($un) && $status == 1) {
                    return redirect()->route('admin.login');
                } else {
                    return view('installation.step0');
                }
            } catch (Exception $e) {
                return view('installation.step0')->with('error', $e->getMessage());
            }
        }
    }

    // Step 1
    public function step1(Request $request)
    {
        if (Hash::check('step_1', $request['token'])) {

            $permission['curl_enabled'] = function_exists('curl_version');
            $permission['env_file'] = is_writable(base_path('.env'));
            $permission['framework_file'] = is_writable(base_path('storage/framework'));
            $permission['logs_file'] = is_writable(base_path('storage/logs'));

            return view('installation.step1', compact('permission'));
        }

        session()->flash('error', __('Label.access_denied'));
        return redirect()->route('step0');
    }

    // Step 2
    public function step2(Request $request)
    {
        if (Hash::check('step_2', $request['token'])) {

            Artisan::call('config:clear');
            $params['purchase_code'] = env(base64_decode('UFVSQ0hBU0VfQ09ERQ=='));
            $params['user_name'] = env(base64_decode('QlVZRVJfVVNFUk5BTUU='));

            return view('installation.step2', $params);
        }
        session()->flash('error', __('Label.access_denied'));
        return redirect()->route('step0');
    }
    public function purchase_code(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'user_name' => 'required',
                'purchase_code' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->first();
                session()->flash('error', $errs);
                return redirect()->route('step2', ['token' => bcrypt('step_2')]);
            }

            $url = url('/');
            $post = [
                base64_decode('cHVyY2hhc2VfY29kZQ==') => $request[base64_decode('cHVyY2hhc2VfY29kZQ==')],
                base64_decode('dXNlcl9uYW1l') => $request[base64_decode('dXNlcl9uYW1l')],
                base64_decode('YnV5ZXJfYWRtaW5fdXJs') => $url
            ];

            try {

                $ch = curl_init(base64_decode('aHR0cHM6Ly92ZXJpZnkuZGl2aW5ldGVjaHMuY29tL3B1YmxpYy9hcGkvdmVyaWZ5X2NvZGU='));
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
                $response = curl_exec($ch);
                $http_status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                $result = json_decode($response);

                if ($http_status == 200) {

                    if (!empty($result) && $result->status == 200) {

                        if ($result->result[0]->item->id == Item_Code()) {

                            $this->common->setEnvironmentValue('PURCHASE_CODE', $request[base64_decode('cHVyY2hhc2VfY29kZQ==')]);
                            $this->common->setEnvironmentValue('BUYER_USERNAME', $result->result[0]->buyer);
                            $this->common->setEnvironmentValue('PURCHASE_STATUS', 0);

                            return redirect()->route('step3', ['token' => bcrypt('step_3')]);
                        } else {

                            session()->flash('error', __('Label.whoops_the_code_you_entered_seems_to_be_for_a_different_product'));
                            return redirect()->route('step2', ['token' => bcrypt('step_2')]);
                        }
                    } else {

                        $this->common->setEnvironmentValue('PURCHASE_CODE', $request[base64_decode('cHVyY2hhc2VfY29kZQ==')]);
                        $this->common->setEnvironmentValue('BUYER_USERNAME', $request[base64_decode('dXNlcl9uYW1l')]);
                        $this->common->setEnvironmentValue('PURCHASE_STATUS', 0);

                        session()->flash('error', $result->message);
                        if (!empty($result->result)) {
                            return redirect()->route('step2', ['token' => bcrypt('step_2')])->with('result', $result->result[0]->buyer_admin_url);
                        } else {
                            return redirect()->route('step2', ['token' => bcrypt('step_2')]);
                        }
                    }
                } else {

                    $this->common->setEnvironmentValue('PURCHASE_CODE', $request[base64_decode('cHVyY2hhc2VfY29kZQ==')]);
                    $this->common->setEnvironmentValue('BUYER_USERNAME', $request[base64_decode('dXNlcl9uYW1l')]);
                    $this->common->setEnvironmentValue('PURCHASE_STATUS', 0);

                    session()->flash('error', __('Label.api_not_working_please_content_on_support_team'));
                    return redirect()->route('step2', ['token' => bcrypt('step_2')]);
                }
            } catch (Exception $e) {
                session()->flash('error', $e->getMessage());
                return back();
            }
        } catch (Exception $e) {
            session()->flash('error', $e->getMessage());
            return back();
        }
    }
    public function update_purchase_code()
    {
        try {

            $url = url('/');
            $post = [
                base64_decode('cHVyY2hhc2VfY29kZQ==') => env(base64_decode('UFVSQ0hBU0VfQ09ERQ==')),
                base64_decode('dXNlcl9uYW1l') => env(base64_decode('QlVZRVJfVVNFUk5BTUU=')),
                base64_decode('YnV5ZXJfYWRtaW5fdXJs') => $url
            ];

            try {

                $ch = curl_init(base64_decode('aHR0cHM6Ly92ZXJpZnkuZGl2aW5ldGVjaHMuY29tL3B1YmxpYy9hcGkvdXBkYXRlX3B1cmNoYXNlX2NvZGU='));
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
                $response = curl_exec($ch);
                $http_status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                $result = json_decode($response);

                if ($http_status == 200) {

                    if (!empty($result) && $result->status == 200) {
                        return redirect()->route('step3', ['token' => bcrypt('step_3')]);
                    } else {

                        session()->flash('error', $result->message);
                        return redirect()->route('step2', ['token' => bcrypt('step_2')]);
                    }
                } else {

                    session()->flash('error', __('Label.api_not_working_please_content_on_support_team'));
                    return redirect()->route('step2', ['token' => bcrypt('step_2')]);
                }
            } catch (Exception $e) {
                session()->flash('error', $e->getMessage());
                return back();
            }
        } catch (Exception $e) {
            session()->flash('error', $e->getMessage());
            return back();
        }
    }

    // Step 3
    public function step3(Request $request)
    {
        if (Hash::check('step_3', $request['token'])) {

            Artisan::call('config:clear');
            $params['db_host'] = env(base64_decode('REJfSE9TVA=='));
            $params['db_database'] = env(base64_decode('REJfREFUQUJBU0U='));
            $params['db_username'] = env(base64_decode('REJfVVNFUk5BTUU='));

            return view('installation.step3', $params);
        }
        session()->flash('error', __('Label.access_denied'));
        return redirect()->route('step0');
    }
    public function database_installation(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'host_name' => 'required',
            'database_name' => 'required',
            'username' => 'required',
        ]);
        if ($validator->fails()) {
            $errs = $validator->errors()->first();
            session()->flash('error', $errs);
            return redirect()->route('step3', ['token' => bcrypt('step_3')]);
        }

        if ($this->check_database_connection($request['host_name'], $request['database_name'], $request['username'], $request['password'])) {

            Artisan::call('config:clear');

            $path = base_path('.env');
            if (file_exists($path)) {

                $file_contents = file_get_contents($path);

                $old_APP_URL = env('APP_URL');
                $old_DB_HOST = env('DB_HOST');
                $old_DB_DATABASE = env('DB_DATABASE');
                $old_DB_USERNAME = env('DB_USERNAME');
                $old_DB_PASSWORD = env('DB_PASSWORD');

                $url = explode('/', url('/'));
                array_pop($url);
                $new_url = implode('/', $url);

                $key = [
                    'APP_URL=' . $old_APP_URL,
                    'DB_HOST=' . $old_DB_HOST,
                    'DB_DATABASE=' . $old_DB_DATABASE,
                    'DB_USERNAME=' . $old_DB_USERNAME,
                    'DB_PASSWORD=' . $old_DB_PASSWORD
                ];
                $value = [
                    'APP_URL=' . $new_url,
                    'DB_HOST=' . $request['host_name'],
                    'DB_DATABASE=' . $request['database_name'],
                    'DB_USERNAME=' . $request['username'],
                    'DB_PASSWORD=' . $request['password']
                ];
                file_put_contents($path, str_replace($key,  $value, $file_contents));

                Artisan::call('config:clear');
            }

            if (!$this->isDatabaseClean($request['host_name'], $request['database_name'], $request['username'], $request['password'])) {
                return redirect()->route('step4', ['token' => $request['token'], 'backup' => base64_encode(1)]);
            } else {
                return redirect()->route('step4', ['token' => $request['token'], 'backup' => base64_encode(0)]);
            }
        } else {

            session()->flash('error', __('Label.database_connection_failed'));
            return redirect()->route('step3', ['token' => bcrypt('step_3')]);
        }
    }
    function check_database_connection($db_host = "", $db_name = "", $db_user = "", $db_pass = "")
    {
        try {
            if (@mysqli_connect($db_host, $db_user, $db_pass, $db_name)) {
                return true;
            } else {
                return false;
            }
        } catch (Exception $e) {
            return false;
        }
    }
    private function isDatabaseClean($db_host, $db_name, $db_user, $db_pass)
    {
        try {
            $mysqli = new \mysqli($db_host, $db_user, $db_pass, $db_name);
            if ($mysqli->connect_error) {
                return false;
            }

            $result = $mysqli->query("SHOW TABLES");
            while ($row = $result->fetch_array()) {
                $table = $row[0];
                $count_result = $mysqli->query("SELECT COUNT(*) as count FROM $table");
                $count_row = $count_result->fetch_assoc();
                if ($count_row['count'] > 0) {
                    return false;
                }
            }
            return true;
        } catch (Exception $e) {
            return false;
        }
    }

    // Step 4
    public function step4(Request $request)
    {
        if (Hash::check('step_4', $request['token']) && base64_decode($request['backup']) == 1 || base64_decode($request['backup']) == 0) {

            $params['backup'] = base64_decode($request['backup']);
            return view('installation.step4', $params);
        }
        session()->flash('error', __('Label.access_denied'));
        return redirect()->route('step0');
    }
    public function backup_db(Request $request)
    {
        try {

            if (Hash::check('backup_db', $request['token'])) {

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

                $file_name = $DbName . '_db_' . date('d_m_Y') . '.sql';
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
            }
            session()->flash('error', __('Label.access_denied'));
            return redirect()->route('step0');
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function import_sql()
    {
        try {

            foreach (DB::select('SHOW TABLES') as $table) {
                $table_array = get_object_vars($table);
                Schema::drop($table_array[key($table_array)]);
            }

            $sql_path = base_path('db/dtpocket_fm.sql');
            if (file_exists($sql_path)) {

                DB::unprepared(file_get_contents($sql_path));
                return redirect()->route('step5', ['token' => bcrypt('step_5')]);
            } else {

                session()->flash('error', __('Label.database_sql_file_not_found'));
                return redirect()->route('step0');
            }
        } catch (Exception $exception) {
            session()->flash('error', __('Label.check_your_database_permission'));
            return back();
        }
    }

    // Step 5
    public function step5(Request $request)
    {
        if (Hash::check('step_5', $request['token'])) {
            return view('installation.step5');
        }
        session()->flash('error', __('Label.access_denied'));
        return redirect()->route('step0');
    }
    public function system_settings(Request $request)
    {
        if (!Hash::check('step_5', $request['token'])) {
            session()->flash('error', __('Label.access_denied'));
            return redirect()->route('step0');
        }

        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|min:4',
        ]);
        if ($validator->fails()) {
            $errs = $validator->errors()->first();
            session()->flash('error', $errs);
            return redirect()->route('step5', ['token' => bcrypt('step_5')]);
        }

        Admin::query()->truncate();

        Admin::create([
            'user_name' => 'Admin',
            'email' => $request['email'],
            'password' => Hash::make($request['password']),
            'status' => 1,
        ]);

        $path = base_path('.env');
        $file_contents = file_get_contents($path);

        $url = explode('/', url('/'));
        array_pop($url);
        $new_url = implode('/', $url);

        $encode_key = base64_decode('UFVSQ0hBU0VfU1RBVFVTPQ==');
        $encode_key1 = base64_decode('QVBQX1VSTD0=');
        $encode_val = env(base64_decode('UFVSQ0hBU0VfU1RBVFVT'));
        $encode_val1 = env(base64_decode('QVBQX1VSTA=='));
        $key = [
            "$encode_key" . "$encode_val",
            "$encode_key1" . "$encode_val1",
        ];
        $value = [
            "$encode_key" . 1,
            "$encode_key1" . $new_url,
        ];

        file_put_contents($path, str_replace($key,  $value, $file_contents));
        Artisan::call('config:clear');

        return view('installation.step6');
    }
}
