// app/Http/Controllers/PayUController.php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use App\Services\PayUService;

class PayUController extends Controller
{
    public function handleSuccess(Request $req) {
        return $this->handleReturn($req, true);
    }

    public function handleFailure(Request $req) {
        return $this->handleReturn($req, false);
    }

    protected function handleReturn(Request $req, bool $isSuccessRoute)
    {
        $post = $req->all();
        if (!isset($post['txnid'], $post['status'], $post['hash'])) {
            return response('Invalid response', 400);
        }

        // Check if record exists
        $payment = DB::table('payments')->where('txnid', $post['txnid'])->first();

        if (!$payment) {
            DB::table('payments')->insert([
                'txnid'        => $post['txnid'],
                'amount'       => $post['amount'] ?? '0',
                'productinfo'  => $post['productinfo'] ?? null,
                'firstname'    => $post['firstname'] ?? null,
                'email'        => $post['email'] ?? null,
                'phone'        => $post['phone'] ?? null,
                'status'       => 'pending',
                'created_at'   => now(),
                'updated_at'   => now(),
            ]);
        }

        // Verify response hash
        $calc = PayUService::responseHash($post, config('payu.salt'));
        $hashOk = hash_equals($calc, strtolower($post['hash']));

        // Determine provisional status
        $provisional = ($isSuccessRoute && $hashOk && ($post['status'] ?? '') === 'success')
            ? 'success' : 'failure';

        DB::table('payments')
            ->where('txnid', $post['txnid'])
            ->update([
                'status'          => $provisional,
                'gateway_payload' => json_encode($post),
                'updated_at'      => now(),
            ]);

        // Optional: verify via PayU Verify API
        $final = $this->verifyWithPayU($post['txnid']);
        if ($final) {
            DB::table('payments')
                ->where('txnid', $post['txnid'])
                ->update([
                    'status'       => $final,
                    'verified_at'  => now(),
                    'updated_at'   => now(),
                ]);
        }

        // Render page
        if (($final ?? $provisional) === 'success') {
            return response()->view('payu.success', ['txnid' => $post['txnid'], 'amount' => $post['amount']]);
        }
        return response()->view('payu.failure', ['txnid' => $post['txnid'], 'amount' => $post['amount']]);
    }

    protected function verifyWithPayU(string $txnid): ?string
    {
        $key = config('payu.key');
        $salt = config('payu.salt');
        $base = config('payu.base_url');
        $command = 'verify_payment';
        $hash = strtolower(hash('sha512', $key.'|'.$command.'|'.$txnid.'|'.$salt));

        $res = Http::asForm()->post($base.'/merchant/postservice?form=2', [
            'key' => $key,
            'command' => $command,
            'var1' => $txnid,
            'hash' => $hash,
        ]);

        if (!$res->ok()) return null;

        $json = $res->json();
        $status = data_get($json, "transaction_details.$txnid.status");

        if (in_array($status, ['success','captured','settled'])) return 'success';
        if (in_array($status, ['failure','dropped','bounced','cancelled'])) return 'failure';
        return null;
    }

    public function status(string $txnid)
    {
        $payment = DB::table('payments')->where('txnid', $txnid)->first();
        if (!$payment) {
            return response()->json(['message' => 'Not found'], 404);
        }
        return response()->json([
            'txnid' => $payment->txnid,
            'status' => $payment->status,
            'verified_at' => $payment->verified_at,
        ]);
    }
}