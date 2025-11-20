# Role-Based Authentication System

## Deskripsi
Sistem ini mengimplementasikan autentikasi berbasis role dengan 2 level akses:
- **User**: Akses ke dashboard Jetstream biasa
- **Admin**: Akses ke panel admin Filament

## Fitur

### 1. Registrasi dengan Role
- Registrasi default sebagai **User**
- Tombol "Daftar sebagai Admin" untuk registrasi admin
- Validasi kode admin: `AdminNihBro`
- Modal popup untuk verifikasi kode admin

### 2. Login dengan Redirect Otomatis
- User biasa → redirect ke `/dashboard` (Jetstream)
- Admin → redirect ke `/admin` (Filament)

### 3. Proteksi Akses
- Middleware `CheckAdminRole` memastikan hanya admin yang bisa akses Filament
- User biasa tidak bisa mengakses `/admin`
- Admin otomatis diarahkan ke panel admin saat mengakses `/dashboard`

## Cara Penggunaan

### Registrasi User Biasa
1. Buka halaman `/register`
2. Isi form registrasi (name, email, password)
3. Klik "Register"
4. User akan terdaftar dengan role `user`

### Registrasi Admin
1. Buka halaman `/register`
2. Klik tombol "🔐 Daftar sebagai Admin"
3. Masukkan kode admin: `AdminNihBro`
4. Klik "Verifikasi"
5. Isi form registrasi
6. Klik "Register"
7. User akan terdaftar dengan role `admin`

### Login
1. Buka halaman `/login`
2. Login dengan credentials
3. Sistem akan otomatis redirect berdasarkan role:
   - User → `/dashboard`
   - Admin → `/admin`

## File yang Dimodifikasi

### Backend
- `database/migrations/2025_11_19_141052_add_role_to_users_table.php` - Menambah kolom role
- `app/Models/User.php` - Menambah method `isAdmin()` dan `isUser()`
- `app/Http/Middleware/CheckAdminRole.php` - Middleware proteksi admin
- `app/Http/Middleware/RedirectBasedOnRole.php` - Middleware redirect berdasarkan role
- `app/Actions/Fortify/CreateNewUser.php` - Validasi registrasi dengan role
- `app/Providers/Filament/AdminPanelProvider.php` - Disable login Filament, gunakan Jetstream
- `app/Providers/FortifyServiceProvider.php` - Custom authentication
- `routes/web.php` - Redirect logic di dashboard

### Frontend
- `resources/js/Pages/Auth/Register.vue` - UI registrasi dengan opsi admin

## Database Schema

Tabel `users` memiliki kolom tambahan:
```sql
role VARCHAR(255) DEFAULT 'user'
```

Nilai yang diperbolehkan:
- `user` (default)
- `admin`

## Security Notes

⚠️ **PENTING**: Kode admin `AdminNihBro` di-hardcode untuk demo. 
Untuk production, pertimbangkan:
1. Simpan kode di environment variable (`.env`)
2. Gunakan sistem invitation/token
3. Implementasi approval system
4. Rate limiting untuk prevent brute force

## Testing

### Test Registrasi User
```bash
# Akses: http://localhost/register
# Isi form → Register
# Role akan otomatis: user
```

### Test Registrasi Admin
```bash
# Akses: http://localhost/register
# Klik "Daftar sebagai Admin"
# Masukkan kode: AdminNihBro
# Isi form → Register
# Role akan: admin
```

### Test Login & Redirect
```bash
# Login sebagai User → akan ke /dashboard
# Login sebagai Admin → akan ke /admin
```

## Troubleshooting

### Issue: Admin tidak bisa akses /admin
**Solusi**: Pastikan migration sudah dijalankan dan user memiliki role 'admin' di database

### Issue: Redirect tidak berfungsi
**Solusi**: Clear cache Laravel
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### Issue: Frontend tidak update
**Solusi**: Rebuild assets
```bash
npm run build
```

## Development

Untuk development mode dengan hot reload:
```bash
npm run dev
```

Untuk production:
```bash
npm run build
```
