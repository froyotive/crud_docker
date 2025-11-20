# Testing Guide - Role-Based Authentication

## Prerequisites

Pastikan sudah menjalankan:
```bash
php artisan migrate
php artisan db:seed --class=AdminUserSeeder
npm run build
```

## Test Accounts

Sistem sudah membuat 2 akun default:

### Admin Account
- **Email**: admin@example.com
- **Password**: password
- **Role**: admin
- **Redirect**: /admin (Filament Panel)

### User Account
- **Email**: user@example.com
- **Password**: password
- **Role**: user
- **Redirect**: /dashboard (Jetstream)

## Test Scenarios

### 1. Test Login sebagai User Biasa

**Langkah:**
1. Buka: http://localhost/login
2. Login dengan:
   - Email: user@example.com
   - Password: password
3. Klik "Log in"

**Expected Result:**
✅ Redirect ke `/dashboard` (Jetstream Dashboard)
✅ Melihat dashboard user biasa dengan menu Jetstream

**Test Akses Admin Panel:**
4. Coba akses: http://localhost/admin

**Expected Result:**
❌ Error 403 - Unauthorized atau redirect ke /dashboard

---

### 2. Test Login sebagai Admin

**Langkah:**
1. Logout dari akun sebelumnya
2. Buka: http://localhost/login
3. Login dengan:
   - Email: admin@example.com
   - Password: password
4. Klik "Log in"

**Expected Result:**
✅ Redirect ke `/admin` (Filament Admin Panel)
✅ Melihat dashboard admin dengan sidebar Filament

**Test Akses Dashboard User:**
5. Coba akses: http://localhost/dashboard

**Expected Result:**
✅ Redirect ke /admin (karena admin harus ke panel admin)

---

### 3. Test Registrasi User Biasa

**Langkah:**
1. Logout dari semua akun
2. Buka: http://localhost/register
3. Isi form:
   - Name: Test User
   - Email: testuser@example.com
   - Password: password123
   - Confirm Password: password123
   - ✅ Accept Terms (jika ada)
4. Klik "Register"

**Expected Result:**
✅ Akun terbuat dengan role 'user'
✅ Auto login
✅ Redirect ke /dashboard

**Verify di Database:**
```sql
SELECT name, email, role FROM users WHERE email = 'testuser@example.com';
```
Expected: role = 'user'

---

### 4. Test Registrasi Admin dengan Kode Valid

**Langkah:**
1. Logout dari semua akun
2. Buka: http://localhost/register
3. Klik tombol "🔐 Daftar sebagai Admin"
4. Akan muncul modal "Masukkan Kode Admin"
5. Masukkan kode: `AdminNihBro`
6. Klik "Verifikasi"
7. Form akan muncul dengan indicator "🔐 Mode Registrasi Admin"
8. Isi form:
   - Name: Test Admin
   - Email: testadmin@example.com
   - Password: password123
   - Confirm Password: password123
   - ✅ Accept Terms (jika ada)
9. Klik "Register"

**Expected Result:**
✅ Akun terbuat dengan role 'admin'
✅ Auto login
✅ Redirect ke /admin (Filament Panel)

**Verify di Database:**
```sql
SELECT name, email, role FROM users WHERE email = 'testadmin@example.com';
```
Expected: role = 'admin'

---

### 5. Test Registrasi Admin dengan Kode Invalid

**Langkah:**
1. Logout dari semua akun
2. Buka: http://localhost/register
3. Klik tombol "🔐 Daftar sebagai Admin"
4. Masukkan kode yang salah: `wrongcode`
5. Klik "Verifikasi"

**Expected Result:**
❌ Muncul error: "Kode admin tidak valid!"
❌ Form tidak muncul
✅ Masih di modal input kode

**Test Cancel:**
6. Klik "Batal"

**Expected Result:**
✅ Modal tertutup
✅ Kembali ke form registrasi normal

---

### 6. Test Toggle Admin Mode

**Langkah:**
1. Buka: http://localhost/register
2. Klik "🔐 Daftar sebagai Admin"
3. Masukkan kode valid: `AdminNihBro`
4. Klik "Verifikasi"
5. Seharusnya muncul indicator "🔐 Mode Registrasi Admin"
6. Klik tombol "❌ Batalkan Mode Admin"

**Expected Result:**
✅ Indicator admin hilang
✅ Tombol berubah kembali ke "🔐 Daftar sebagai Admin"
✅ Form kembali ke mode registrasi user biasa

---

### 7. Test Auto Redirect setelah Login

**Test A - Admin Login:**
1. Login sebagai admin
2. Secara manual akses: http://localhost/dashboard

**Expected Result:**
✅ Auto redirect ke /admin

**Test B - User Login:**
1. Login sebagai user
2. Secara manual akses: http://localhost/admin

**Expected Result:**
❌ Error 403 atau redirect ke /dashboard

---

### 8. Test Direct Access tanpa Login

**Test A - Dashboard:**
1. Logout dari semua akun
2. Akses: http://localhost/dashboard

**Expected Result:**
✅ Redirect ke /login

**Test B - Admin Panel:**
1. Logout dari semua akun
2. Akses: http://localhost/admin

**Expected Result:**
✅ Redirect ke /login

---

## Database Verification

### Check User Roles
```sql
SELECT id, name, email, role, created_at 
FROM users 
ORDER BY created_at DESC;
```

### Count Users by Role
```sql
SELECT role, COUNT(*) as total 
FROM users 
GROUP BY role;
```

### Find All Admins
```sql
SELECT name, email 
FROM users 
WHERE role = 'admin';
```

---

## Common Issues & Solutions

### Issue 1: Admin tidak bisa akses /admin
**Cause**: Role tidak terset atau middleware tidak jalan
**Solution**:
```bash
# Check user role in database
php artisan tinker
>>> User::where('email', 'admin@example.com')->first()->role;

# Clear cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### Issue 2: Redirect loop
**Cause**: Middleware bentrok
**Solution**: Check middleware di routes/web.php dan AdminPanelProvider.php

### Issue 3: Registration tidak save role
**Cause**: Mass assignment tidak allow 'role'
**Solution**: Check $fillable di User model harus include 'role'

### Issue 4: Kode admin tidak terverifikasi
**Cause**: Kode di .env berbeda dengan yang diinput
**Solution**:
```bash
# Check admin code
cat .env | grep ADMIN_REGISTRATION_CODE

# Or in tinker
php artisan tinker
>>> config('app.admin_registration_code');
```

### Issue 5: UI tidak update setelah edit Vue
**Cause**: Assets belum di-compile ulang
**Solution**:
```bash
npm run build
# Or for development
npm run dev
```

---

## Performance Testing

### Load Test Login
```bash
# Buat banyak user untuk testing
php artisan tinker
>>> User::factory(100)->create(['role' => 'user']);
>>> User::factory(10)->create(['role' => 'admin']);
```

### Test Concurrent Access
1. Buka 2 browser berbeda
2. Login sebagai admin di browser 1
3. Login sebagai user di browser 2
4. Test akses ke /admin dan /dashboard dari kedua browser

**Expected**:
✅ Admin bisa akses /admin di browser 1
✅ User bisa akses /dashboard di browser 2
❌ User tidak bisa akses /admin
✅ Admin auto redirect dari /dashboard ke /admin

---

## Security Testing

### Test 1: Brute Force Admin Code
- ❌ Tidak ada rate limiting untuk modal kode admin
- ⚠️ **Recommendation**: Tambahkan rate limiting di verifyAdminCode()

### Test 2: SQL Injection
- ✅ Menggunakan Eloquent ORM (protected)

### Test 3: XSS in Registration
- ✅ Laravel auto-escapes output

### Test 4: CSRF
- ✅ CSRF token sudah dihandle oleh Laravel

---

## Next Steps

Setelah semua test passed:

1. ✅ Update ADMIN_REGISTRATION_CODE di .env untuk production
2. ✅ Setup email verification jika diperlukan
3. ✅ Tambahkan rate limiting untuk prevent brute force
4. ✅ Setup proper logging untuk security events
5. ✅ Implementasi approval system untuk admin registration (optional)

---

## Test Checklist

- [ ] Login sebagai user → redirect ke /dashboard ✓
- [ ] Login sebagai admin → redirect ke /admin ✓
- [ ] User tidak bisa akses /admin ✓
- [ ] Admin auto redirect dari /dashboard ke /admin ✓
- [ ] Registrasi user biasa berhasil ✓
- [ ] Registrasi admin dengan kode valid berhasil ✓
- [ ] Registrasi admin dengan kode invalid ditolak ✓
- [ ] Toggle admin mode berfungsi ✓
- [ ] Akses tanpa login redirect ke /login ✓
- [ ] Database role tersimpan dengan benar ✓

---

**Last Updated**: November 19, 2025
**Status**: ✅ Ready for Testing
