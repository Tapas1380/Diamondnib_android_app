<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Support\Facades\Artisan;

class Installation
{

    public function handle(Request $request, Closure $next)
    {
        try {

            Artisan::call('config:clear');

            $verflyDomain = Demo_Domain();
            if ($verflyDomain == 1) {

                return $next($request);
            } else {

                $pc = env(base64_decode('UFVSQ0hBU0VfQ09ERQ=='));
                $un = env(base64_decode('QlVZRVJfVVNFUk5BTUU='));
                $status = env(base64_decode('UFVSQ0hBU0VfU1RBVFVT'));

                if (!empty($pc) && !empty($un) && $status == 1) {

                    if (@mysqli_connect(env('DB_HOST'), env('DB_USERNAME'), env('DB_PASSWORD'), env('DB_DATABASE'))) {

                        return $next($request);
                    } else {
                        return redirect()->route('step0');
                    }
                } else {
                    return redirect()->route('step0');
                }
            }
        } catch (Exception $e) {
            session()->flash('error', $e->getMessage());
            return redirect()->route('step0');
        }
    }
}
