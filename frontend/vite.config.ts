import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: '../static',
    emptyOutDir: true,
    sourcemap: true
  },
  server: {
    proxy: {
      '/ask': 'http://localhost:8001',
      '/chat': 'http://localhost:8001',
      '/conversation': 'http://localhost:8001',
      '/history': 'http://localhost:8001',
      '/.auth': 'http://localhost:8001',
      '/frontend_settings': 'http://localhost:8001'
    }
  }
})
