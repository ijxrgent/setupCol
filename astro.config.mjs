// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

// Cambia esto por tu dominio real cuando lo tengas (lo usa el sitemap y las URLs canónicas)
export default defineConfig({
  site: 'https://www.ejemplo.com',
  trailingSlash: 'always',
  build: { format: 'directory' }, // genera /guias/x/index.html -> CloudFront Function lo resuelve
  integrations: [sitemap()],
  vite: { plugins: [tailwindcss()] },
});
