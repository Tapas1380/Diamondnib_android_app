<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Common;
use App\Models\User;
use App\Models\Wallet_Transaction;
use Illuminate\Http\Request;
use Exception;

class WalletController extends Controller
{
    private $folder = "user";
    public $common;
    public function __construct()
    {
        $this->common = new Common;
    }

    public function index(Request $request)
    {
        try {

            $params['data'] = [];

            $input_search = $request['input_search'];
            if ($input_search != null && isset($input_search)) {
                $params['data'] = User::where('wallet_coin', '!=', 0)
                    ->where(function ($query) use ($input_search) {
                        $query->where('user_name', 'LIKE', "%{$input_search}%")
                            ->orWhere('full_name', 'LIKE', "%{$input_search}%")
                            ->orWhere('email', 'LIKE', "%{$input_search}%")
                            ->orWhere('mobile_number', 'LIKE', "%{$input_search}%");
                    })
                    ->orderBy('id', 'DESC')->paginate(15);
            } else {
                $params['data'] = User::where('wallet_coin', '!=', 0)->orderBy('id', 'DESC')->paginate(15);
            }
            $this->common->imageNameToUrl($params['data'], 'image', $this->folder);

            return view('admin.wallet.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function WalletTransaction($id, Request $request)
    {
        try {

            $params['data'] = [];
            $params['id'] = $id;

            if ($request->ajax()) {

                $data = Wallet_Transaction::where('user_id', $id)->with('user', 'content', 'episode')->latest()->orderby('id', 'desc')->get();

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('date', function ($row) {
                        $date = date("Y-m-d", strtotime($row->created_at));
                        return $date;
                    })
                    ->make(true);
            }

            return view('admin.wallet.transaction', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
}
