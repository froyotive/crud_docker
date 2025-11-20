# Bug Fix - Registrasi User Biasa Tidak Bisa

## 🐛 Problem
User biasa tidak bisa melakukan registrasi. Setelah mengisi form dan menekan tombol "Register", form tidak ter-submit.

## 🔍 Root Cause Analysis

### Issue 1: Validasi admin_code
Di `CreateNewUser.php`, field `admin_code` memiliki validasi:
```php
'admin_code' => ['required_if:role,admin', 'string'],
```

Ketika user biasa mendaftar, form tetap mengirim:
```javascript
{
  role: 'user',
  admin_code: '',  // ← String kosong menyebabkan validasi error
}
```

Meskipun `required_if:role,admin` seharusnya skip validasi jika role != admin, tapi karena field `admin_code` ada dan berisi string kosong, validator tetap cek rule `'string'`.

### Issue 2: Form mengirim field yang tidak perlu
Register.vue mengirim semua field termasuk `admin_code` dan `role` meskipun user mendaftar sebagai user biasa.

## ✅ Solution

### Fix 1: Update Validasi (CreateNewUser.php)
Tambahkan `'nullable'` pada `admin_code` validation:

```php
'admin_code' => ['nullable', 'required_if:role,admin', 'string'],
```

**Penjelasan:**
- `nullable` → Allow null atau tidak ada field
- `required_if:role,admin` → Hanya required jika role = admin
- `string` → Harus string jika ada

### Fix 2: Form Transform (Register.vue)
Gunakan `form.transform()` untuk hanya mengirim field yang diperlukan:

```javascript
const submit = () => {
    form.transform((data) => {
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
```

**Penjelasan:**
- User biasa: Hanya kirim name, email, password, password_confirmation, terms
- Admin: Kirim semua field + role + admin_code
- Lebih clean dan predictable

## 📊 Before vs After

### Before (Broken)
**User Biasa Registrasi:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "terms": true,
  "role": "user",           // ← Tidak perlu
  "admin_code": ""          // ← String kosong, cause validation error
}
```
❌ Result: Validation error / Form tidak submit

### After (Fixed)
**User Biasa Registrasi:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "terms": true
}
```
✅ Result: Success! Role otomatis 'user' (dari CreateNewUser default)

**Admin Registrasi:**
```json
{
  "name": "Admin User",
  "email": "admin@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "terms": true,
  "role": "admin",
  "admin_code": "AdminNihBro"
}
```
✅ Result: Success! Role = 'admin'

## 🧪 Testing

### Test Case 1: User Biasa
1. Buka: http://localhost:8000/register
2. Isi form:
   - Name: Test User
   - Email: test@example.com
   - Password: password123
   - Confirm: password123
   - ✅ Terms
3. Klik "Register"

**Expected:**
✅ Form submitted
✅ User created with role 'user'
✅ Auto login
✅ Redirect to /dashboard

### Test Case 2: Admin
1. Buka: http://localhost:8000/register
2. Klik "🔐 Daftar sebagai Admin"
3. Input kode: AdminNihBro
4. Klik "Verifikasi"
5. Isi form:
   - Name: Test Admin
   - Email: testadmin@example.com
   - Password: password123
   - Confirm: password123
   - ✅ Terms
6. Klik "Register"

**Expected:**
✅ Form submitted
✅ User created with role 'admin'
✅ Auto login
✅ Redirect to /admin

## 📝 Files Changed

1. **app/Actions/Fortify/CreateNewUser.php**
   - Line 29: Added `'nullable'` to admin_code validation

2. **resources/js/Pages/Auth/Register.vue**
   - Line 56-71: Updated `submit()` function with form.transform()

## 🚀 Deployment

```bash
# Rebuild assets
npm run build

# Clear cache (optional)
php artisan config:clear
php artisan cache:clear
```

## ✅ Verification

Setelah fix, kedua scenario harus berhasil:
- ✅ User biasa bisa register
- ✅ Admin bisa register dengan kode
- ✅ No validation errors
- ✅ Proper redirect based on role

---

**Fixed Date**: November 19, 2025
**Status**: ✅ **RESOLVED**
**Build**: Success
**Tested**: ✅ Both scenarios working
