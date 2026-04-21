-- =========================================================
-- FINANZAS PERSONALES - Setup de Supabase
-- Pegá este script en: Supabase → SQL Editor → New query → Run
-- =========================================================

create extension if not exists "pgcrypto";

-- Categorías (ingresos / egresos)
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('income','expense')),
  icon text,
  color text,
  created_at timestamptz default now()
);

-- Movimientos (transacciones)
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  amount numeric(14,2) not null,
  type text not null check (type in ('income','expense')),
  category_id uuid references public.categories(id) on delete set null,
  date date not null default current_date,
  note text,
  created_at timestamptz default now()
);

create index if not exists tx_date_idx on public.transactions(date desc);
create index if not exists tx_cat_idx  on public.transactions(category_id);

-- Modo personal: usar anon key sin RLS.
-- Si la app va a ser multi-usuario, habilitá RLS y agregá políticas por auth.uid().
alter table public.categories  disable row level security;
alter table public.transactions disable row level security;
