import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  base: './',
  plugins: [vue()],
  server: {
    port: 5173,
    host: true,
    allowedHosts: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/images': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/letters': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/receipts': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/patrols': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
});
