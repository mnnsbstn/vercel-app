const TOKEN_KEY = "vercel_manager_pat";

export function getToken(): string | null {
  return sessionStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string) {
  sessionStorage.setItem(TOKEN_KEY, token);
}

export function clearToken() {
  sessionStorage.removeItem(TOKEN_KEY);
}

export async function vercelGet<T>(path: string, teamId?: string | null): Promise<T> {
  const token = getToken();
  if (!token) throw new Error("Nicht angemeldet");

  let url = `/api/vercel${path}`;
  if (teamId) {
    const sep = url.includes("?") ? "&" : "?";
    url += `${sep}teamId=${encodeURIComponent(teamId)}`;
  }

  const res = await fetch(url, {
    headers: { "X-Vercel-Token": token, Accept: "application/json" },
  });
  const text = await res.text();
  if (!res.ok) {
  let message = text;
  try {
    const j = JSON.parse(text) as { error?: { message?: string } };
    message = j.error?.message ?? text;
  } catch {
    /* raw */
  }
  if (res.status === 401) throw new Error("Token ungültig oder abgelaufen.");
  throw new Error(`Vercel API (${res.status}): ${message}`);
  }
  return JSON.parse(text) as T;
}