# projek_akhir_pab

Prototype aplikasi Flutter untuk BangJun.

## Prasyarat
- Flutter SDK (stable)
- Android Studio / SDK (untuk Android)
- Visual Studio + Desktop development with C++ (untuk Windows)

## Setup Cepat
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Siapkan env:
   - Salin `assets/.env.example` menjadi `assets/.env`
   - Isi nilai `SUPABASE_URL` dan `SUPABASE_ANON_KEY`
3. Setup database Supabase (1 file):
   - Buat dulu user di Supabase Auth:
     - `admin@bangjun.id`
     - `kasir@bangjun.id`
   - Jalankan `supabase/run_all.sql` di Supabase SQL Editor

## Menjalankan
- Android: `flutter run` / `flutter build apk`
- Web: `flutter run -d chrome` / `flutter build web`
- Windows: `flutter run -d windows` / `flutter build windows`
