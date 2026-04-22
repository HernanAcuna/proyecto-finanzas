/* ============================================================
   Service Worker — Finanzas Personales
   Estrategia:
   - Network-first para el HTML propio (siempre sirve la versión más nueva)
   - Cache-first para recursos CDN externos (Tailwind, Chart.js, Supabase)
   - El usuario controla cuándo aplicar la actualización (no auto-reload)
   ============================================================ */

const SW_VERSION = '1.1.0';
const CACHE_APP  = `finanzas-app-${SW_VERSION}`;
const CACHE_CDN  = `finanzas-cdn-${SW_VERSION}`;

const CDN_ORIGINS = [
  'https://cdn.tailwindcss.com',
  'https://cdn.jsdelivr.net',
];

// ---- INSTALL: precachear recursos CDN ----
self.addEventListener('install', event => {
  // NO llamamos skipWaiting() aquí.
  // El nuevo SW espera hasta que el usuario confirme la actualización.
  event.waitUntil(
    caches.open(CACHE_CDN).then(cache =>
      cache.addAll([
        'https://cdn.tailwindcss.com',
        'https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js',
        'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
      ]).catch(() => {}) // Si algún CDN falla, no bloqueamos la instalación
    )
  );
});

// ---- ACTIVATE: limpiar caches viejos y tomar control de todos los clientes ----
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys
          .filter(k => k !== CACHE_APP && k !== CACHE_CDN)
          .map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

// ---- MESSAGE: la app puede triggear skipWaiting manualmente ----
self.addEventListener('message', event => {
  if (event.data === 'skipWaiting') self.skipWaiting();
});

// ---- FETCH ----
self.addEventListener('fetch', event => {
  const req = event.request;
  const url = new URL(req.url);

  // Solo manejamos GET
  if (req.method !== 'GET') return;

  // Ignorar requests de Supabase API (auth, datos) — siempre van a la red
  if (url.hostname.includes('supabase.co')) return;

  const isSameOrigin = url.origin === self.location.origin;
  const isCDN = CDN_ORIGINS.some(o => req.url.startsWith(o));

  // HTML propio: network-first, fallback a cache (para modo offline)
  if (isSameOrigin && (req.mode === 'navigate' || url.pathname.endsWith('.html') || url.pathname === '/')) {
    event.respondWith(
      fetch(req, { cache: 'no-store' })
        .then(res => {
          // Guardamos copia fresca para offline
          const clone = res.clone();
          caches.open(CACHE_APP).then(c => c.put(req, clone));
          return res;
        })
        .catch(() =>
          caches.match(req)
            .then(cached => cached || caches.match('/'))
        )
    );
    return;
  }

  // CDN externos: cache-first, fallback a network
  if (isCDN) {
    event.respondWith(
      caches.match(req).then(cached => {
        if (cached) return cached;
        return fetch(req).then(res => {
          const clone = res.clone();
          caches.open(CACHE_CDN).then(c => c.put(req, clone));
          return res;
        });
      })
    );
    return;
  }

  // Resto: network directo
  event.respondWith(fetch(req));
});
