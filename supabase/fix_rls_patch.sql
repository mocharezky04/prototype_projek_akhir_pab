-- ============================================================
-- PATCH: Fix RLS policies untuk BangJun Spot
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Stock movements: kasir perlu read untuk hitung stok di kasir page
drop policy if exists "stock admin" on stock_movements;

-- Admin bisa semua (insert, update, delete, select)
create policy "stock admin write" on stock_movements for all
  using (is_admin()) with check (is_admin());

-- Kasir (dan admin) bisa baca stock movements
create policy "stock read authenticated" on stock_movements for select
  using (auth.uid() is not null);

-- ============================================================
-- 2. Profiles: admin bisa baca semua profil (untuk settings page)
--    Sudah ada tapi pastikan read mencakup is_admin juga
-- ============================================================
drop policy if exists "profiles read" on profiles;

create policy "profiles read" on profiles for select
  using (auth.uid() = id or is_admin());

-- ============================================================
-- 3. Transaction items: kasir perlu bisa read untuk riwayat
-- ============================================================
drop policy if exists "transaction_items read" on transaction_items;

create policy "transaction_items read" on transaction_items for select
  using (
    is_admin()
    or exists (
      select 1 from transactions t
      where t.id = transaction_id
        and t.cashier_id = auth.uid()
    )
  );

-- ============================================================
-- 4. Fungsi is_admin() sudah ada, tapi kalau role bisa 'admin'
--    atau 'kasir', pastikan konsisten dengan app
-- ============================================================
create or replace function is_admin() returns boolean as $$
  select exists(
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  );
$$ language sql stable security definer;

-- ============================================================
-- SELESAI. Tes dengan akun kasir:
-- - Bisa lihat products
-- - Bisa baca stock_movements (baru)
-- - Bisa insert transactions
-- - Tidak bisa insert/update/delete products
-- ============================================================
