# 🚀 Quick Start - Role-Based Authentication System

## Setup dalam 5 Menit

### 1. Install Dependencies
```bash
composer install
npm install --legacy-peer-deps
```

### 2. Setup Environment
```bash
cp .env.example .env
php artisan key:generate
```

### 3. Setup Database
Edit `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=crud
DB_USERNAME=root
DB_PASSWORD=
```

### 4. Migrate & Seed
```bash
php artisan migrate
php artisan db:seed --class=AdminUserSeeder
```

### 5. Build Assets
```bash
npm run build
```

### 6. Start Server
```bash
php artisan serve
```

## 🔐 Default Accounts

| Role | Email | Password | Redirect To |
|------|-------|----------|-------------|
| Admin | admin@example.com | password | /admin (Filament) |
| User | user@example.com | password | /dashboard (Jetstream) |

## 📝 Admin Registration Code

Default: `AdminNihBro`

Ubah di `.env`:
```env
ADMIN_REGISTRATION_CODE=YourSecretCode
```

## 🎯 Quick Test

1. **Test User Login**
   - Go to: http://localhost:8000/login
   - Login: user@example.com / password
   - Should redirect to: /dashboard

2. **Test Admin Login**
   - Go to: http://localhost:8000/login
   - Login: admin@example.com / password
   - Should redirect to: /admin

3. **Test Admin Registration**
   - Go to: http://localhost:8000/register
   - Click: "🔐 Daftar sebagai Admin"
   - Enter code: AdminNihBro
   - Fill form and register
   - Should redirect to: /admin

## 📚 Documentation

- [Full Documentation](ROLE_BASED_AUTH.md)
- [Testing Guide](TESTING_GUIDE.md)

## 🎨 Features

✅ Role-based authentication (User & Admin)  
✅ Auto redirect based on role  
✅ Admin registration with secret code  
✅ Protected admin panel (Filament)  
✅ User dashboard (Jetstream)  
✅ Modern UI with Tailwind CSS  

## 🛠️ Tech Stack

- Laravel 11
- Laravel Jetstream (Inertia + Vue 3)
- Filament 3
- Tailwind CSS 4
- Vite 6

## 📞 Support

Jika ada masalah, lihat [TESTING_GUIDE.md](TESTING_GUIDE.md) bagian "Common Issues & Solutions"

---

**Happy Coding! 🎉**
