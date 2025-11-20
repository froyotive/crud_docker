<?php

namespace App\Actions\Fortify;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Laravel\Fortify\Contracts\CreatesNewUsers;
use Laravel\Jetstream\Jetstream;

class CreateNewUser implements CreatesNewUsers
{
    use PasswordValidationRules;

    /**
     * Validate and create a newly registered user.
     *
     * @param  array<string, string>  $input
     */
    public function create(array $input): User
    {
        Validator::make($input, [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => $this->passwordRules(),
            'terms' => Jetstream::hasTermsAndPrivacyPolicyFeature() ? ['accepted', 'required'] : '',
            'role' => ['nullable', 'string', 'in:user,admin'],
            'admin_code' => ['nullable', 'required_if:role,admin', 'string'],
        ])->validate();

        // Validate admin code if role is admin
        if (isset($input['role']) && $input['role'] === 'admin') {
            $adminCode = config('app.admin_registration_code', 'AdminNihBro');
            if (!isset($input['admin_code']) || $input['admin_code'] !== $adminCode) {
                throw \Illuminate\Validation\ValidationException::withMessages([
                    'admin_code' => ['Kode admin tidak valid.'],
                ]);
            }
        }

        return User::create([
            'name' => $input['name'],
            'email' => $input['email'],
            'password' => Hash::make($input['password']),
            'role' => $input['role'] ?? 'user',
        ]);
    }
}
