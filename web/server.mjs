#!/usr/bin/env node
/**
 * Production server: static dist/ + Vercel API proxy (token via X-Vercel-Token header).
 */
import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { join, extname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const staticRoot = join(__dirname, "dist");
const port = Number(process.env.PORT || 4173);

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json",
  ".png": "image/png",
  ".webmanifest": "application/manifest+json",
  ".svg": "image/svg+xml",
};

async function proxyVercel(req, res, restPath, search) {
  const token = req.headers["x-vercel-token"];
  if (typeof token !== "string" || !token.trim()) {
    res.writeHead(401, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Kein Token (X-Vercel-Token)" }));
    return;
  }
  const target = `https://api.vercel.com${restPath}${search || ""}`;
  try {
    const upstream = await fetch(target, {
      method: req.method ?? "GET",
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
      },
    });
    const body = await upstream.arrayBuffer();
    res.writeHead(upstream.status, {
      "Content-Type": upstream.headers.get("content-type") || "application/json",
    });
    res.end(Buffer.from(body));
  } catch {
    res.writeHead(502, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Vercel API nicht erreichbar" }));
  }
}

async function serveFile(res, path) {
  const data = await readFile(path);
  const ext = extname(path);
  res.writeHead(200, { "Content-Type": MIME[ext] || "application/octet-stream" });
  res.end(data);
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${req.headers.host}`);

  if (url.pathname.startsWith("/api/vercel")) {
    const rest = url.pathname.replace(/^\/api\/vercel/, "") || "/";
    await proxyVercel(req, res, rest, url.search);
    return;
  }

  let filePath = join(staticRoot, url.pathname === "/" ? "index.html" : url.pathname);
  try {
    const st = await stat(filePath);
    if (st.isDirectory()) filePath = join(filePath, "index.html");
    await serveFile(res, filePath);
  } catch {
    if (!extname(url.pathname)) await serveFile(res, join(staticRoot, "index.html"));
    else {
      res.writeHead(404);
      res.end("Not found");
    }
  }
});

server.listen(port, "127.0.0.1", () => {
  console.log(`Vercel Manager Web → http://127.0.0.1:${port}`);
});