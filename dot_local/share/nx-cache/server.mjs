// Managed by chezmoi. A local Nx remote cache shared by every Nx workspace
// and worktree on this Mac.
//
// It implements the Nx self-hosted remote cache API: GET and PUT
// /v1/cache/<hash>, the body an opaque tarball. Nx talks to it when
// NX_SELF_HOSTED_REMOTE_CACHE_SERVER points here.
//
// Security: it listens on 127.0.0.1 only and refuses any Host header that is
// not this loopback address, so a web page cannot reach it through DNS
// rebinding, and it sends no CORS headers, so a page cannot PUT to it. An
// entry is never overwritten (409), so a poisoned write cannot replace a good
// artifact (CVE-2025-36852).
import { randomUUID } from "node:crypto";
import { createReadStream, createWriteStream } from "node:fs";
import { link, mkdir, readdir, rm, stat, utimes } from "node:fs/promises";
import { createServer } from "node:http";
import { homedir } from "node:os";
import { join } from "node:path";
import { pipeline } from "node:stream/promises";

const port = Number(process.env.NX_CACHE_PORT ?? 4380);
const root =
  process.env.NX_CACHE_ROOT ?? join(homedir(), "Library/Caches/nx-remote-cache");
const maxAgeDays = Number(process.env.NX_CACHE_MAX_AGE_DAYS ?? 14);
const allowedHosts = new Set([`127.0.0.1:${port}`, `localhost:${port}`]);
const hashPattern = /^[A-Za-z0-9_-]{1,128}$/;

const entriesDir = join(root, "entries");
const incomingDir = join(root, "incoming");

const log = (message) => console.log(`${new Date().toISOString()} ${message}`);

const send = (response, status, body = "") => {
  response.writeHead(status, { "Content-Type": "text/plain" });
  response.end(body);
};

const retrieve = async (path, response) => {
  const info = await stat(path).catch(() => null);
  if (!info) return send(response, 404, "not found");
  // Touch the entry so pruning keeps what is still used.
  const now = new Date();
  await utimes(path, now, now).catch(() => {});
  response.writeHead(200, {
    "Content-Type": "application/octet-stream",
    "Content-Length": info.size,
  });
  await pipeline(createReadStream(path), response);
};

const store = async (hash, path, request, response) => {
  const incoming = join(incomingDir, `${hash}.${randomUUID()}`);
  try {
    await pipeline(request, createWriteStream(incoming, { flags: "wx" }));
    // link() fails if the entry exists: no overwrite, and readers never see
    // a half-written file.
    await link(incoming, path);
    send(response, 200);
  } catch (error) {
    if (error.code === "EEXIST") send(response, 409, "already exists");
    else throw error;
  } finally {
    await rm(incoming, { force: true });
  }
};

const handle = async (request, response) => {
  if (!allowedHosts.has(request.headers.host ?? "")) {
    return send(response, 403, "forbidden host");
  }
  const match = /^\/v1\/cache\/([^/?]+)$/.exec(request.url ?? "");
  if (!match || !hashPattern.test(match[1])) return send(response, 404, "not found");
  const hash = match[1];
  const path = join(entriesDir, hash);
  if (request.method === "GET") return retrieve(path, response);
  if (request.method === "PUT") return store(hash, path, request, response);
  send(response, 405, "method not allowed");
};

const prune = async () => {
  const cutoff = Date.now() - maxAgeDays * 24 * 60 * 60 * 1000;
  let removed = 0;
  for (const name of await readdir(entriesDir)) {
    const path = join(entriesDir, name);
    const info = await stat(path).catch(() => null);
    if (info && info.mtimeMs < cutoff) {
      await rm(path, { force: true });
      removed += 1;
    }
  }
  if (removed) log(`pruned ${removed} entries older than ${maxAgeDays} days`);
};

// Leftovers of uploads interrupted by a crash or restart.
await rm(incomingDir, { recursive: true, force: true });
await mkdir(incomingDir, { recursive: true });
await mkdir(entriesDir, { recursive: true });
await prune();
setInterval(() => prune().catch((error) => log(`prune failed: ${error}`)), 6 * 60 * 60 * 1000);

createServer((request, response) => {
  handle(request, response).catch((error) => {
    log(`${request.method} ${request.url} failed: ${error}`);
    if (!response.headersSent) send(response, 500, "internal error");
    else response.destroy();
  });
}).listen(port, "127.0.0.1", () => log(`nx cache on 127.0.0.1:${port}, storing in ${root}`));
