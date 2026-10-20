// Detox — push delivery (Firebase Cloud Messaging HTTP v1).
//
// Called by the database (private.notify, through pg_net) with a shared
// secret. The database decides who is notified and what the text is; this
// function only looks up the device tokens and sends.
//
// Secrets (set by the CI, never in the repo):
//   FIREBASE_SERVICE_ACCOUNT  JSON key of the Firebase service account
//   PUSH_SECRET               shared with private.push_config
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase.

import { createClient } from "npm:@supabase/supabase-js@2";

type Payload = {
  user_ids: string[];
  title: string;
  body: string;
  data?: Record<string, unknown>;
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

const encoder = new TextEncoder();

function base64Url(bytes: Uint8Array | string): string {
  const raw = typeof bytes === "string" ? encoder.encode(bytes) : bytes;
  let binary = "";
  for (const b of raw) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): ArrayBuffer {
  const body = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const binary = atob(body);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

let cachedToken: { value: string; expiresAt: number } | null = null;

/** OAuth access token for FCM, from a service-account signed JWT (RS256). */
async function accessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt - 60 > now) return cachedToken.value;

  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64Url(JSON.stringify({
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, encoder.encode(`${header}.${claims}`)),
  );
  const jwt = `${header}.${claims}.${base64Url(signature)}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!response.ok) throw new Error(`oauth ${response.status}: ${await response.text()}`);
  const json = await response.json();
  cachedToken = { value: json.access_token, expiresAt: now + (json.expires_in ?? 3600) };
  return cachedToken.value;
}

/** Constant-time comparison of the shared secret. */
function sameSecret(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return new Response("method not allowed", { status: 405 });

  const secret = Deno.env.get("PUSH_SECRET") ?? "";
  if (!secret || !sameSecret(request.headers.get("x-push-secret") ?? "", secret)) {
    return new Response("unauthorized", { status: 401 });
  }

  let payload: Payload;
  try {
    payload = await request.json();
  } catch {
    return new Response("bad json", { status: 400 });
  }
  if (!Array.isArray(payload.user_ids) || payload.user_ids.length === 0 || !payload.title) {
    return Response.json({ sent: 0 });
  }

  const account: ServiceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}");
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const { data: rows, error } = await supabase
    .from("push_tokens")
    .select("token")
    .in("user_id", payload.user_ids);
  if (error) return new Response(`tokens: ${error.message}`, { status: 500 });

  const token = await accessToken(account);
  // FCM data values must be strings.
  const data = Object.fromEntries(
    Object.entries(payload.data ?? {}).map(([k, v]) => [k, typeof v === "string" ? v : JSON.stringify(v)]),
  );

  let sent = 0;
  const stale: string[] = [];
  await Promise.all((rows ?? []).map(async ({ token: deviceToken }) => {
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`,
      {
        method: "POST",
        headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          message: {
            token: deviceToken,
            notification: { title: payload.title, body: payload.body },
            data,
            android: {
              priority: "high",
              notification: { channel_id: "detox", color: "#8B5CF6", tag: data.kind ?? undefined },
            },
          },
        }),
      },
    );
    if (response.ok) {
      sent++;
      return;
    }
    const text = await response.text();
    // Uninstalled app or expired token: forget it.
    if (response.status === 404 || text.includes("UNREGISTERED") || text.includes("INVALID_ARGUMENT")) {
      stale.push(deviceToken);
    } else {
      console.error(`fcm ${response.status}: ${text}`);
    }
  }));

  if (stale.length > 0) await supabase.from("push_tokens").delete().in("token", stale);
  return Response.json({ sent, removed: stale.length });
});
