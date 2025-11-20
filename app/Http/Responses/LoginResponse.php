<?php

namespace App\Http\Responses;

use Laravel\Fortify\Contracts\LoginResponse as LoginResponseContract;
use Illuminate\Http\JsonResponse;

class LoginResponse implements LoginResponseContract
{
    /**
     * Create an HTTP response that represents the object.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function toResponse($request)
    {
        // Get the authenticated user
        $user = auth()->user();

        // Redirect based on user role
        if ($user && $user->isAdmin()) {
            return $request->wantsJson()
                ? new JsonResponse('', 204)
                : redirect()->intended('/admin');
        }

        // Default redirect for regular users
        return $request->wantsJson()
            ? new JsonResponse('', 204)
            : redirect()->intended(config('fortify.home'));
    }
}
