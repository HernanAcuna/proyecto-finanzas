-- =========================================================
-- FINANZAS PERSONALES - Setup completo de Supabase
-- Incluye: schema con user_id, RLS, políticas y migración
-- Pegá este script en: Supabase → SQL Editor → New query → Run
-- =========================================================

create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────────────────
-- TABLA: categories
-- ─────────────────────────────────────────────────────────
create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  name       text not null,
  type       text not null check (type in ('income','expense')),
  icon       text,
  color      text,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────
-- TABLA: transactions
-- ─────────────────────────────────────────────────────────
create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade not null,
  amount      numeric(14,2) not null,
  type        text not null check (type in ('income','expense')),
  category_id uuid references public.categories(id) on delete set null,
  date        date not null default current_date,
  note        text,
  created_at  timestamptz default now()
);

-- ─────────────────────────────────────────────────────────
-- ÍNDICES
-- ─────────────────────────────────────────────────────────
create index if not exists cats_user_idx  on public.categories(user_id);
create index if not exists cats_type_idx  on public.categories(user_id, type);
create index if not exists tx_user_idx    on public.transactions(user_id);
create index if not exists tx_date_idx    on public.transactions(user_id, date desc);
create index if not exists tx_cat_idx     on public.transactions(category_id);

-- ─────────────────────────────────────────────────────────
-- RLS: habilitar en ambas tablas
-- ─────────────────────────────────────────────────────────
alter table public.categories  enable row level security;
alter table public.transactions enable row level security;

-- ─────────────────────────────────────────────────────────
-- POLÍTICAS: categories
-- ─────────────────────────────────────────────────────────
drop policy if exists "Usuarios: ver propias categorías"    on public.categories;
drop policy if exists "Usuarios: insertar propias categorías" on public.categories;
drop policy if exists "Usuarios: actualizar propias categorías" on public.categories;
drop policy if exists "Usuarios: eliminar propias categorías"  on public.categories;

create policy "Usuarios: ver propias categorías"
  on public.categories for select
  using (auth.uid() = user_id);

create policy "Usuarios: insertar propias categorías"
  on public.categories for insert
  with check (auth.uid() = user_id);

create policy "Usuarios: actualizar propias categorías"
  on public.categories for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Usuarios: eliminar propias categorías"
  on public.categories for delete
  using (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────
-- POLÍTICAS: transactions
-- ─────────────────────────────────────────────────────────
drop policy if exists "Usuarios: ver propias transacciones"    on public.transactions;
drop policy if exists "Usuarios: insertar propias transacciones" on public.transactions;
drop policy if exists "Usuarios: actualizar propias transacciones" on public.transactions;
drop policy if exists "Usuarios: eliminar propias transacciones"  on public.transactions;

create policy "Usuarios: ver propias transacciones"
  on public.transactions for select
  using (auth.uid() = user_id);

create policy "Usuarios: insertar propias transacciones"
  on public.transactions for insert
  with check (auth.uid() = user_id);

create policy "Usuarios: actualizar propias transacciones"
  on public.transactions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Usuarios: eliminar propias transacciones"
  on public.transactions for delete
  using (auth.uid() = user_id);


-- =========================================================
-- MIGRACIÓN: si ya tenés tablas existentes SIN user_id,
-- ejecutá este bloque SEPARADO después del setup inicial.
-- Reemplazá 'TU-USER-UUID-AQUÍ' con tu auth.uid() real
-- (lo encontrás en Supabase → Authentication → Users).
-- =========================================================

-- PASO 1: Agregar la columna user_id si aún no existe
-- ALTER TABLE public.categories  ADD COLUMN IF NOT EXISTS user_id uuid;
-- ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS user_id uuid;

-- PASO 2: Asignar tu user_id a todos los registros existentes
-- UPDATE public.categories  SET user_id = 'TU-USER-UUID-AQUÍ' WHERE user_id IS NULL;
-- UPDATE public.transactions SET user_id = 'TU-USER-UUID-AQUÍ' WHERE user_id IS NULL;

-- PASO 3: Hacer la columna NOT NULL y agregar FK
-- ALTER TABLE public.categories  ALTER COLUMN user_id SET NOT NULL;
-- ALTER TABLE public.categories  ADD CONSTRAINT categories_user_fk
--   FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
-- ALTER TABLE public.transactions ALTER COLUMN user_id SET NOT NULL;
-- ALTER TABLE public.transactions ADD CONSTRAINT transactions_user_fk
--   FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- PASO 4: Habilitar RLS (volver a ejecutar el bloque de políticas de arriba)
