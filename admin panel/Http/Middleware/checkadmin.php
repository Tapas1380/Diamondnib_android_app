<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class checkadmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, $guard = null)
    {
        if (env('DEMO_MODE') == 'ON') {
            return back()->with('error', __('Label.you_have_no_right_to_add_edit_and_delete'));
        }
        return $next($request);
    }
}
