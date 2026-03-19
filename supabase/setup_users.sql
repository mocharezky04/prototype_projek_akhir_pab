-- ============================================================
-- STEP 1: Jalankan fix_rls_patch_safe.sql dulu
-- STEP 2: Baru jalankan file ini
-- ============================================================

-- A. Pastikan admin@bangjun.id punya role 'admin'
insert into profiles (id, email, role)
select
  au.id,
  au.email,
  'admin'
from auth.users au
where au.email = 'admin@bangjun.id'
  and not exists (
    select 1 from profiles p where p.id = au.id
  );

update profiles
set role = 'admin'
where email = 'admin@bangjun.id'
  and role != 'admin';

-- B. Buat akun kasir@bangjun.id di Dashboard:
-- Authentication -> Users -> Add user (Auto Confirm User)

-- C. Setelah kasir dibuat di Authentication, set rolenya jadi 'kasir'
insert into profiles (id, email, role)
select
  au.id,
  au.email,
  'kasir'
from auth.users au
where au.email = 'kasir@bangjun.id'
  and not exists (
    select 1 from profiles p where p.id = au.id
  );

update profiles
set role = 'kasir'
where email = 'kasir@bangjun.id'
  and role != 'kasir';

-- D. Verifikasi hasil
select
  au.email,
  p.role,
  p.created_at,
  case
    when p.id is null then 'BELUM ADA DI PROFILES'
    else 'OK'
  end as status
from auth.users au
left join profiles p on p.id = au.id
where au.email in ('admin@bangjun.id', 'kasir@bangjun.id')
order by au.email;
