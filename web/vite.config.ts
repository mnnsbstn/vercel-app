import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  plugins: [
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["apple-touch-icon.png", "icons/*.png"],
      manifest: false,
      workbox: {
        globPatterns: ["**/*.{js,css,html,ico,png,svg,webmanifest}"],
        navigateFallback: "/index.html",
      },
    }),
  ],
  server: {
    port: 5173,
    strictPort: true,
    proxy: {
      "/api/vercel": {
        target: "https://api.vercel.com",
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/vercel/, ""),
        configure: (proxy) => {
          proxy.on("proxyReq", (proxyReq, req) => {
            const token = req.headers["x-vercel-token"];
            if (typeof token === "string" && token.length > 0) {
              proxyReq.setHeader("Authorization", `Bearer ${token}`);
            }
            proxyReq.removeHeader("x-vercel-token");
          });
        },
      },
    },
  },
});