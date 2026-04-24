<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Common;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Exception;

class MetaCapiController extends Controller
{
    public $common;

    public function __construct()
    {
        try {
            $this->common = new Common();
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }

    private function normalizeAndHash($value)
    {
        $value = trim(strtolower((string) $value));
        if ($value === '') return '';
        return hash('sha256', $value);
    }

    public function track(Request $request)
    {
        try {
            $validation = Validator::make($request->all(), [
                'event_name' => 'required|string',
                'event_id' => 'required|string',
                'user_id' => 'nullable|string',
                'email' => 'nullable|string',
                'phone' => 'nullable|string',
                'value' => 'nullable|numeric',
                'currency' => 'nullable|string',
            ]);

            if ($validation->fails()) {
                return ['status' => 400, 'message' => $validation->errors()->first()];
            }

            $pixelId = env('META_PIXEL_ID', '');
            $accessToken = env('META_CAPI_ACCESS_TOKEN', '');

            if (empty($pixelId) || empty($accessToken)) {
                return $this->common->API_Response(400, 'Meta CAPI not configured.');
            }

            $eventName = $request->event_name;
            $eventId = $request->event_id;

            $userData = [];
            $emailHash = $this->normalizeAndHash($request->email ?? '');
            $phoneHash = $this->normalizeAndHash($request->phone ?? '');
            $externalIdHash = $this->normalizeAndHash($request->user_id ?? '');

            if (!empty($emailHash)) $userData['em'] = [$emailHash];
            if (!empty($phoneHash)) $userData['ph'] = [$phoneHash];
            if (!empty($externalIdHash)) $userData['external_id'] = [$externalIdHash];

            $customData = [];
            if (!empty($request->value)) {
                $customData['value'] = (float) $request->value;
            }
            if (!empty($request->currency)) {
                $customData['currency'] = $request->currency;
            }

            $payload = [
                'data' => [
                    [
                        'event_name' => $eventName,
                        'event_time' => time(),
                        'action_source' => 'app',
                        'event_id' => $eventId,
                        'user_data' => (object) $userData,
                        'custom_data' => (object) $customData,
                    ]
                ]
            ];

            $url = 'https://graph.facebook.com/v20.0/' . $pixelId . '/events?access_token=' . $accessToken;
            $resp = Http::timeout(10)->post($url, $payload);

            if ($resp->successful()) {
                return $this->common->API_Response(200, 'Meta CAPI event sent successfully.', [$resp->json()]);
            }

            return $this->common->API_Response(400, 'Meta CAPI request failed.', [$resp->json()]);
        } catch (Exception $e) {
            return response()->json(['status' => 400, 'errors' => $e->getMessage()]);
        }
    }
}
