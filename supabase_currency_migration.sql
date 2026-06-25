-- =========================================================
-- MIGRACIÓN: Soporte multi-moneda en transactions
-- Agrega columna 'currency' a la tabla transactions.
-- Valores posibles: 'ARS' (default) | 'USD'
--
-- Pegá este script en: Supabase → SQL Editor → New query → Run
-- =========================================================

-- PASO 1: Agregar columna currency con default 'ARS'
alter table public.transactions
  add column if not exists currency text not null default 'ARS'
  check (currency in ('ARS', 'USD'));

-- PASO 2: Asegurar que registros existentes tengan 'ARS'
update public.transactions
  set currency = 'ARS'
  where currency is null;

-- PASO 3: Índice para acelerar consultas por moneda
create index if not exists tx_currency_idx on public.transactions(user_id, currency);

-- VERIFICACIÓN: debería mostrar todas las filas con currency = 'ARS'
-- select id, amount, type, currency from public.transactions limit 10;
