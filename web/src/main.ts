import "./styles.css";
import {
  clearToken,
  getToken,
  setToken,
  vercelGet,
} from "./api";

type UserResponse = { user: { username?: string; name?: string; email?: string } };
type TeamsResponse = { teams: { id: string; name: string; slug: string }[] };
type ProjectsResponse = {
  projects: { id: string; name: string; framework?: string; updatedAt?: number }[];
};

const app = document.querySelector<HTMLDivElement>("#app")!;

let teamId: string | null = null;
let view: "login" | "projects" | "settings" = getToken() ? "projects" : "login";

function escapeHtml(s: string) {
  return s.replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!,
  );
}

function renderLogin(error?: string) {
  app.innerHTML = `
    <img class="app-icon" src="/apple-touch-icon.png" width="64" height="64" alt="" />
    <h1>Vercel Manager</h1>
    <p class="lead">Deine Projekte und Deployments. Als Web-App — auch vom iPhone-Homescreen.</p>
    <p class="label">VERCEL VERBINDEN</p>
  ${error ? `<div class="error">${escapeHtml(error)}</div>` : ""}
    <input type="password" id="token" placeholder="Personal Access Token" autocomplete="off" />
    <button class="btn" id="connect">Verbinden</button>
    <button class="btn btn-ghost" type="button" id="open-tokens">Token bei Vercel erstellen</button>
    <p class="disclaimer">
      Inoffizielle App, nicht von Vercel betrieben. Token liegt in <strong>sessionStorage</strong>
      (Browser) — sicherer ist die native iOS-App (Keychain). Icon = App-Icon dieser App, nicht das Vercel-Markenlogo.
    </p>
  `;
  document.querySelector<HTMLButtonElement>("#open-tokens")!.onclick = () =>
    window.open("https://vercel.com/account/tokens", "_blank", "noopener");
  document.querySelector<HTMLButtonElement>("#connect")!.onclick = async () => {
    const input = document.querySelector<HTMLInputElement>("#token")!;
    const token = input.value.trim();
    if (!token) return;
    const btn = document.querySelector<HTMLButtonElement>("#connect")!;
    btn.disabled = true;
    btn.textContent = "Verbinden…";
    try {
      setToken(token);
      await vercelGet<UserResponse>("/v2/user");
      view = "projects";
      render();
    } catch (e) {
      clearToken();
      renderLogin(e instanceof Error ? e.message : "Verbindung fehlgeschlagen");
    }
  };
}

async function renderProjects() {
  app.innerHTML = `
    <img class="app-icon" src="/apple-touch-icon.png" alt="" />
    <h1>Projekte</h1>
    <nav class="tabs">
      <button type="button" data-tab="projects" class="active">Projekte</button>
      <button type="button" data-tab="settings">Einstellungen</button>
    </nav>
    <div id="list" class="spinner">Laden…</div>
  `;
  app.querySelector<HTMLButtonElement>('[data-tab="settings"]')!.onclick = () => {
    view = "settings";
    render();
  };
  try {
    const data = await vercelGet<ProjectsResponse>("/v9/projects?limit=50", teamId);
    const list = document.querySelector("#list")!;
    if (!data.projects.length) {
      list.innerHTML = `<p class="muted">Keine Projekte in diesem Scope.</p>`;
      return;
    }
    list.innerHTML = data.projects
      .map(
        (p) => `
      <article class="card">
        <h3>${escapeHtml(p.name)}</h3>
        <p class="muted">${escapeHtml(p.framework ?? "—")}</p>
      </article>`,
      )
      .join("");
  } catch (e) {
    document.querySelector("#list")!.innerHTML = `<div class="error">${escapeHtml(
      e instanceof Error ? e.message : "Fehler",
    )}</div>`;
  }
}

async function renderSettings() {
  let user = "—";
  let teams: TeamsResponse["teams"] = [];
  try {
    const u = await vercelGet<UserResponse>("/v2/user");
    user = u.user.username ?? u.user.name ?? u.user.email ?? "—";
    const t = await vercelGet<TeamsResponse>("/v2/teams");
    teams = t.teams;
  } catch {
    /* show logout anyway */
  }

  app.innerHTML = `
    <h1>Einstellungen</h1>
    <nav class="tabs">
      <button type="button" data-tab="projects">Projekte</button>
      <button type="button" data-tab="settings" class="active">Einstellungen</button>
    </nav>
    <p class="label">ACCOUNT</p>
    <p>${escapeHtml(user)}</p>
    <p class="label">TEAM-SCOPE</p>
    <select id="team" style="width:100%;padding:12px;border-radius:12px;background:#111;color:#fff;border:1px solid #2a2a2a">
      <option value="">Persönlicher Account</option>
      ${teams.map((t) => `<option value="${escapeHtml(t.id)}" ${teamId === t.id ? "selected" : ""}>${escapeHtml(t.name)}</option>`).join("")}
    </select>
    <button class="btn btn-ghost" id="logout">Abmelden</button>
    <p class="disclaimer">Version 1.0.0 (Web) · PWA: Safari → Teilen → Zum Home-Bildschirm.</p>
  `;
  app.querySelector<HTMLButtonElement>('[data-tab="projects"]')!.onclick = () => {
    view = "projects";
    render();
  };
  const sel = app.querySelector<HTMLSelectElement>("#team")!;
  sel.onchange = () => {
    teamId = sel.value || null;
    view = "projects";
    render();
  };
  app.querySelector<HTMLButtonElement>("#logout")!.onclick = () => {
    clearToken();
    teamId = null;
    view = "login";
    render();
  };
}

function render() {
  if (view === "login") renderLogin();
  else if (view === "settings") void renderSettings();
  else void renderProjects();
}

render();

if ("serviceWorker" in navigator) {
  import("virtual:pwa-register").then(({ registerSW }) => registerSW({ immediate: true }));
}