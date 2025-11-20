<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RedirectBasedOnRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (auth()->check()) {
            $user = auth()->user();
            
            // If admin trying to access non-admin routes, redirect to admin panel
            if ($user->isAdmin() && !$request->is('admin*')) {
                return redirect('/admin');
            }
            
            // If regular user trying to access admin routes, redirect to dashboard
            if ($user->isUser() && $request->is('admin*')) {
                return redirect('/dashboard');
            }
        }
        
        return $next($request);
    }
}
