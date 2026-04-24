<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthAdmin
{
    public function handle(Request $request, Closure $next)
    {

        if (Auth::guard('admin')->guest()) {
            if (!$request->ajax() || !$request->wantsJson()) {
                return redirect(route('admin.logout'));
            }
        }
        return $next($request);
    }
}
