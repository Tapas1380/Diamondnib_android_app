<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Common;
use App\Models\Package;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class TransactionController extends Controller
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
            $params['package'] = Package::latest()->get();
            if ($request->ajax()) {

                $input_type = $request['input_type'];
                $input_package = $request['input_package'];
                $input_search = $request['input_search'];

                if ($input_package != 0) {
                    if ($input_type == "today") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->with('package', 'user')->where('package_id', $input_package)
                                ->whereDay('created_at', date('d'))->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->where('package_id', $input_package)->whereDay('created_at', date('d'))
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else if ($input_type == "month") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->where('package_id', $input_package)->with('package', 'user')
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->where('package_id', $input_package)->whereMonth('created_at', date('m'))
                                ->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else if ($input_type == "year") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->where('package_id', $input_package)->with('package', 'user')->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->where('package_id', $input_package)->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->where('package_id', $input_package)->with('package', 'user')->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->where('package_id', $input_package)->orderBy('status', 'desc')->latest()->get();
                        }
                    }
                } else {
                    if ($input_type == "today") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->with('package', 'user')->whereDay('created_at', date('d'))
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->whereDay('created_at', date('d'))
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else if ($input_type == "month") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->with('package', 'user')
                                ->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->whereMonth('created_at', date('m'))->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else if ($input_type == "year") {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->with('package', 'user')->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->whereYear('created_at', date('Y'))->orderBy('status', 'desc')->latest()->get();
                        }
                    } else {

                        if ($input_search != null && isset($input_search)) {
                            $data = Transaction::where('transaction_id', 'LIKE', "%{$input_search}%")->with('package', 'user')->orderBy('status', 'desc')->latest()->get();
                        } else {
                            $data = Transaction::with('package', 'user')->orderBy('status', 'desc')->latest()->get();
                        }
                    }
                }

                for ($i = 0; $i < count($data); $i++) {
                    $data[$i]['date'] = date("d-m-Y", strtotime($data[$i]['created_at']));
                }

                return DataTables()::of($data)->addIndexColumn()->make(true);
            }
            return view('admin.transaction.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function create(Request $request)
    {
        try {
            $params['data'] = [];
            $params['user'] = User::where('id', $request->user_id)->first();
            $params['package'] = Package::get();

            return view('admin.transaction.add', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function searchUser(Request $request)
    {
        try {
            $name = $request->name;
            $user = User::orWhere('full_name', 'like', '%' . $name . '%')->orWhere('mobile_number', 'like', '%' . $name . '%')->orWhere('email', 'like', '%' . $name . '%')->latest()->get();

            $url = url('admin/transaction/create?user_id');
            $text = '<table width="100%" class="table table-striped category-table text-center table-bordered"><tr style="background: #F9FAFF;"><th>Full Name</th><th>Mobile</th><th>Email</th><th>Action</th></tr>';
            if ($user->count() > 0) {
                foreach ($user as $row) {

                    $a = '<a class="btn-link" href="' . $url . '=' . $row->id . '">Select</a>';
                    $text .= '<tr><td>' . $row->full_name . '</td><td>' . $row->mobile_number . '</td><td>' . $row->email . '</td><td>' . $a . '</td></tr>';
                }
            } else {
                $text .= '<tr><td colspan="4">User Not Found</td></tr>';
            }
            $text .= '</table>';

            return response()->json(array('status' => 200, 'success' => 'Search User', 'result' => $text));
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required',
                'package_id' => 'required'
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $package = Package::where('id', $request->package_id)->first();

            $Transction = new Transaction();
            $Transction->user_id = $request->user_id;
            $Transction->package_id = $request->package_id;
            $Transction->description = 'admin';
            $Transction->price = $package->price;
            $Transction->coin = $package->coin;
            $Transction->transaction_id = 'admin';
            $Transction->status = 1;

            if ($Transction->save()) {
                if ($Transction->id) {

                    User::where('id', $request->user_id)->increment('wallet_coin', $package->coin);

                    return response()->json(array('status' => 200, 'success' => __('Label.Transction_Add_Successfully')));
                } else {
                    return response()->json(array('status' => 400, 'errors' => __('Label.Transction_Not_Add')));
                }
            } else {
                return response()->json(array('status' => 400, 'errors' => __('Label.Transction_Not_Add')));
            }
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
