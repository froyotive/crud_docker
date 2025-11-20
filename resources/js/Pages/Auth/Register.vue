<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import { ref } from 'vue';
import AuthenticationCard from '@/Components/AuthenticationCard.vue';
import AuthenticationCardLogo from '@/Components/AuthenticationCardLogo.vue';
import Checkbox from '@/Components/Checkbox.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';

const isAdminMode = ref(false);
const showAdminCodePrompt = ref(false);
const adminCodeInput = ref('');
const adminCodeError = ref('');

const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    terms: false,
    role: 'user',
    admin_code: '',
});

const toggleAdminMode = () => {
    if (!isAdminMode.value) {
        showAdminCodePrompt.value = true;
    } else {
        isAdminMode.value = false;
        form.role = 'user';
        form.admin_code = '';
        adminCodeInput.value = '';
        adminCodeError.value = '';
    }
};

const verifyAdminCode = () => {
    if (adminCodeInput.value === 'AdminNihBro') {
        isAdminMode.value = true;
        showAdminCodePrompt.value = false;
        form.role = 'admin';
        form.admin_code = adminCodeInput.value;
        adminCodeError.value = '';
    } else {
        adminCodeError.value = 'Kode admin tidak valid!';
    }
};

const cancelAdminMode = () => {
    showAdminCodePrompt.value = false;
    adminCodeInput.value = '';
    adminCodeError.value = '';
};

const submit = () => {
    form.transform((data) => {
        // Create clean data object
        const cleanData = {
            name: data.name,
            email: data.email,
            password: data.password,
            password_confirmation: data.password_confirmation,
            terms: data.terms,
        };

        // Only include role and admin_code if in admin mode
        if (isAdminMode.value) {
            cleanData.role = 'admin';
            cleanData.admin_code = data.admin_code;
        }

        return cleanData;
    }).post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};
</script>

<template>
    <Head title="Register" />

    <AuthenticationCard>
        <template #logo>
            <AuthenticationCardLogo />
        </template>

        <form @submit.prevent="submit">
            <!-- Admin Mode Indicator -->
            <div v-if="isAdminMode" class="mb-4 p-4 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 rounded-md">
                <p class="text-sm font-medium text-amber-800 dark:text-amber-200">
                    🔐 Mode Registrasi Admin
                </p>
            </div>

            <div>
                <InputLabel for="name" value="Name" />
                <TextInput
                    id="name"
                    v-model="form.name"
                    type="text"
                    class="mt-1 block w-full"
                    required
                    autofocus
                    autocomplete="name"
                />
                <InputError class="mt-2" :message="form.errors.name" />
            </div>

            <div class="mt-4">
                <InputLabel for="email" value="Email" />
                <TextInput
                    id="email"
                    v-model="form.email"
                    type="email"
                    class="mt-1 block w-full"
                    required
                    autocomplete="username"
                />
                <InputError class="mt-2" :message="form.errors.email" />
            </div>

            <div class="mt-4">
                <InputLabel for="password" value="Password" />
                <TextInput
                    id="password"
                    v-model="form.password"
                    type="password"
                    class="mt-1 block w-full"
                    required
                    autocomplete="new-password"
                />
                <InputError class="mt-2" :message="form.errors.password" />
            </div>

            <div class="mt-4">
                <InputLabel for="password_confirmation" value="Confirm Password" />
                <TextInput
                    id="password_confirmation"
                    v-model="form.password_confirmation"
                    type="password"
                    class="mt-1 block w-full"
                    required
                    autocomplete="new-password"
                />
                <InputError class="mt-2" :message="form.errors.password_confirmation" />
            </div>

            <div v-if="$page.props.jetstream.hasTermsAndPrivacyPolicyFeature" class="mt-4">
                <InputLabel for="terms">
                    <div class="flex items-center">
                        <Checkbox id="terms" v-model:checked="form.terms" name="terms" required />

                        <div class="ms-2">
                            I agree to the <a target="_blank" :href="route('terms.show')" class="underline text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:focus:ring-offset-gray-800">Terms of Service</a> and <a target="_blank" :href="route('policy.show')" class="underline text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:focus:ring-offset-gray-800">Privacy Policy</a>
                        </div>
                    </div>
                    <InputError class="mt-2" :message="form.errors.terms" />
                </InputLabel>
            </div>

            <div class="flex items-center justify-end mt-4">
                <Link :href="route('login')" class="underline text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 dark:focus:ring-offset-gray-800">
                    Already registered?
                </Link>

                <PrimaryButton class="ms-4" :class="{ 'opacity-25': form.processing }" :disabled="form.processing">
                    Register
                </PrimaryButton>
            </div>

            <!-- Admin Registration Toggle Button -->
            <div class="mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                <button
                    type="button"
                    @click="toggleAdminMode"
                    class="w-full text-center px-4 py-2 bg-amber-100 dark:bg-amber-900/30 text-amber-800 dark:text-amber-200 rounded-md hover:bg-amber-200 dark:hover:bg-amber-900/50 transition-colors"
                >
                    {{ isAdminMode ? '❌ Batalkan Mode Admin' : '🔐 Daftar sebagai Admin' }}
                </button>
            </div>
        </form>

        <!-- Admin Code Prompt Modal -->
        <div v-if="showAdminCodePrompt" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div class="bg-white dark:bg-gray-800 rounded-lg p-6 max-w-md w-full mx-4">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
                    Masukkan Kode Admin
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
                    Untuk mendaftar sebagai admin, silakan masukkan kode admin yang valid.
                </p>
                <div>
                    <InputLabel for="admin_code" value="Kode Admin" />
                    <TextInput
                        id="admin_code"
                        v-model="adminCodeInput"
                        type="password"
                        class="mt-1 block w-full"
                        placeholder="Masukkan kode admin"
                        @keyup.enter="verifyAdminCode"
                    />
                    <p v-if="adminCodeError" class="mt-2 text-sm text-red-600 dark:text-red-400">
                        {{ adminCodeError }}
                    </p>
                </div>
                <div class="flex items-center justify-end mt-6 space-x-3">
                    <button
                        type="button"
                        @click="cancelAdminMode"
                        class="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600"
                    >
                        Batal
                    </button>
                    <button
                        type="button"
                        @click="verifyAdminCode"
                        class="px-4 py-2 bg-amber-600 text-white rounded-md hover:bg-amber-700"
                    >
                        Verifikasi
                    </button>
                </div>
            </div>
        </div>
    </AuthenticationCard>
</template>
