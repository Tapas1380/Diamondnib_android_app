<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Payment_Option;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class PaymentController extends Controller
{
    public function index(Request $request)
    {
        try {
            $params['data'] = [];
            if ($request->ajax()) {

                $input_search = $request['input_search'];

                if ($input_search != null && isset($input_search)) {
                    $data = Payment_Option::where('name', 'LIKE', "%{$input_search}%")->get();
                } else {
                    $data = Payment_Option::get();
                }

                return DataTables()::of($data)
                    ->addIndexColumn()
                    ->addColumn('action', function ($row) {
                        $btn = '<a href="' . route('payment.edit', [$row->id]) . '" class="edit-delete-btn" title="Edit"><i class="fa-solid fa-pen-to-square fa-xl"></i></a>';
                        return $btn;
                    })
                    ->rawColumns(['action'])
                    ->make(true);
            }
            return view('admin.payment.index', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function edit($id)
    {
        try {

            $params['data'] = Payment_Option::where('id', $id)->first();
            return view('admin.payment.edit', $params);
        } catch (Exception $e) {
            return response()->json(array('status' => 400, 'errors' => $e->getMessage()));
        }
    }
    public function update(Request $request)
    {
        try {

            $validator = Validator::make($request->all(), [
                'visibility' => 'required',
                'is_live' => 'required',
            ]);
            if ($validator->fails()) {
                $errs = $validator->errors()->all();
                return response()->json(array('status' => 400, 'errors' => $errs));
            }

            $payment_option = Payment_Option::where('id', $request->id)->first();

            $data = $request->all();
            $payment_option->key_1 = isset($data['key_1']) ? $data['key_1'] : '';
            $payment_option->key_2 = isset($data['key_2']) ? $data['key_2'] : '';
            $payment_option->key_3 = isset($data['key_3']) ? $data['key_3'] : '';

            if (isset($payment_option->id)) {

                $payment_option->visibility = $request->visibility;
                $payment_option->is_live = $request->is_live;

                if ($payment_option->save()) {
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
