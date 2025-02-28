#!/bin/bash
#ddev-generated

JS_CONFIG="${DDEV_APPROOT}/vite.config.js"
TS_CONFIG="${DDEV_APPROOT}/vite.config.ts"

if [ -f "$JS_CONFIG" ]; then
  CONFIG_FILE="$JS_CONFIG"
elif [ -f "$TS_CONFIG" ]; then
  CONFIG_FILE="$TS_CONFIG"
else
  exit 0
fi

if grep -q "const port = 5173;" "$CONFIG_FILE" && \
   grep -q "const origin = \`\${process.env.DDEV_PRIMARY_URL}:\${port}\`;" "$CONFIG_FILE" && \
   grep -q "export default defineConfig({" "$CONFIG_FILE" && \
   grep -q "server: {" "$CONFIG_FILE" && \
   grep -q "host: '0.0.0.0'" "$CONFIG_FILE"; then
  exit 0
fi

cat > "$CONFIG_FILE" << 'EOL'
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import laravel from 'laravel-vite-plugin';
import { resolve } from 'node:path';
import { defineConfig } from 'vite';

const port = 5173;
const origin = `${process.env.DDEV_PRIMARY_URL}:${port}`;

export default defineConfig({
    server: {
        host: '0.0.0.0',
        port: port,
        strictPort: true,
        origin: origin,
        cors: {
            origin: process.env.DDEV_PRIMARY_URL,
        },
    },
    plugins: [
        laravel({
            input: 'resources/js/app.tsx',
            ssr: 'resources/js/ssr.tsx',
            refresh: true,
        }),
        react(),
        tailwindcss(),
    ],
    resolve: {
        alias: {
            'ziggy-js': resolve(__dirname, 'vendor/tightenco/ziggy'),
        },
    },
});
EOL