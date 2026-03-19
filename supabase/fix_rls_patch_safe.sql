-- ============================================================
-- SAFE PATCH: Tambah policy tanpa drop yang lama
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1) Stock movements: kasir perlu READ
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'stock_movements'
      and policyname = 'stock read authenticated'
  ) then
    create policy "stock read authenticated" on stock_movements
      for select
      using (auth.uid() is not null);
  end if;
end $$;

-- 2) Profiles: admin bisa baca semua profil
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and policyname = 'profiles read admin'
  ) then
    create policy "profiles read admin" on profiles
      for select
      using (is_admin());
  end if;
end $$;

-- 3) Transaction items: kasir perlu bisa READ untuk riwayat
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'transaction_items'
      and policyname = 'transaction_items read cashier'
  ) then
    create policy "transaction_items read cashier" on transaction_items
      for select
      using (
        is_admin()
        or exists (
          select 1 from transactions t
          where t.id = transaction_id
            and t.cashier_id = auth.uid()
        )
      );
  end if;
end $$;

-- 4) is_admin() tetap, hanya replace jika belum konsisten
create or replace function is_admin() returns boolean as $$
  select exists(
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  );
$$ language sql stable security definer;
