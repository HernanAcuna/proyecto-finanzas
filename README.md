# Finanzas Personales (estilo Money Manager)

App web de una sola página, modo oscuro, moneda ARS.

## Archivos

- `index.html` — app completa (abrí con doble clic en el navegador).
- `supabase_setup.sql` — script para crear tablas en Supabase.

## Cómo usarla

1. Abrí `index.html` en Chrome/Edge/Firefox. Ya funciona sin Supabase (guarda datos en el navegador).
2. En la pantalla **Inicio** tocás `+ INGRESO` o `− EGRESO` → aparece el teclado numérico + categorías.
3. **Dashboard** muestra balances del mes, gráfico de torta por categoría y total histórico.
4. **Categorías** te deja crear/editar/borrar categorías (ícono emoji + color).
5. **Ajustes** → pegás URL y Anon Key de Supabase y se sincroniza.

## Setup de Supabase (opcional, para nube)

1. Entrá a supabase.com y creá un proyecto.
2. Copiá `URL` y `anon public key` de *Project Settings → API*.
3. Abrí el **SQL Editor** y pegá el contenido de `supabase_setup.sql`. Run.
4. En la app → pestaña **Ajustes** → pegá URL y Anon key → *Guardar y conectar*.
5. La app sube las categorías por defecto la primera vez y sincroniza.

## Stack

- HTML + Tailwind (CDN) + Chart.js + Supabase JS (CDN).
- Sin build, sin dependencias locales.
- Persistencia local con `localStorage`, sincronización con Supabase si está configurado.

## Atajos de teclado (dentro del modal de movimiento)

- Dígitos y `,` / `.` escriben en el teclado.
- `Enter` guarda, `Esc` cancela, `Backspace` borra.
