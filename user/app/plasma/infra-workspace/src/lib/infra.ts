import { execFile } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { Color, Icon, runInTerminal, showToast, Toast } from "@vicinae/api";

export type Env = "prod" | "preprod" | "staging" | "dev" | "lab";

export type Infra = {
  title: string;
  env: Env;
  kube?: string;
  talos?: string;
  openstackCloud?: string;
  argocdNamespace?: string;
  alertmanager?: { namespace: string; service: string; port: number };
  boundary?: { addr: string };
  vault?: { addr: string };
  grafanaTokenFile?: string;
  links: Record<string, string>;
};

export type Config = {
  infras: Record<string, Infra>;
  gitlab?: { host: string; tokenFile?: string };
  runbooks?: { dirs: string[]; hubUrl?: string };
};

const home = homedir();
const configPath = join(process.env.XDG_CONFIG_HOME ?? join(home, ".config"), "infra", "infras.json");
const stateDir = join(process.env.XDG_STATE_HOME ?? join(home, ".local", "state"), "infra");
const currentPath = join(stateDir, "current");

export const expandHome = (p: string) => (p.startsWith("~/") ? join(home, p.slice(2)) : p);

export function loadConfig(): Config {
  try {
    return JSON.parse(readFileSync(configPath, "utf8")) as Config;
  } catch (err) {
    throw new Error(`cannot read ${configPath}: ${(err as Error).message}`);
  }
}

export function currentInfraName(cfg: Config): string | undefined {
  try {
    const name = readFileSync(currentPath, "utf8").trim();
    if (name in cfg.infras) return name;
  } catch {
    // no infra selected yet
  }
  return Object.keys(cfg.infras)[0];
}

export function activeInfra(cfg: Config): [string, Infra] | undefined {
  const name = currentInfraName(cfg);
  return name ? [name, cfg.infras[name]] : undefined;
}

export const envColor: Record<Env, Color> = {
  prod: Color.Red,
  preprod: Color.Orange,
  staging: Color.Yellow,
  dev: Color.Green,
  lab: Color.Blue,
};

export const envTag = (infra: Infra) => ({ tag: { value: infra.env, color: envColor[infra.env] } });

const serviceIcons: Record<string, Icon> = {
  grafana: Icon.LineChart,
  argocd: Icon.Rocket,
  vault: Icon.Lock,
  gitlab: Icon.Code,
  keycloak: Icon.Key,
  ceph: Icon.HardDrive,
  prometheus: Icon.Gauge,
  alertmanager: Icon.Bell,
  openstack: Icon.Cloud,
  boundary: Icon.Network,
  harbor: Icon.Box,
  longhorn: Icon.HardDrive,
};

export const serviceIcon = (service: string) => serviceIcons[service] ?? Icon.Globe01;

export type ExecResult = { stdout: string; stderr: string };

export function sh(cmd: string, args: string[], opts: { timeoutMs?: number; env?: NodeJS.ProcessEnv } = {}): Promise<ExecResult> {
  return new Promise((resolve, reject) => {
    execFile(
      cmd,
      args,
      { timeout: opts.timeoutMs ?? 15000, maxBuffer: 64 * 1024 * 1024, env: { ...process.env, ...opts.env } },
      (err, stdout, stderr) => {
        if (err) {
          const detail = stderr.trim().split("\n").slice(-2).join(" ") || err.message;
          reject(new Error(`${cmd} ${args.slice(0, 3).join(" ")}: ${detail}`));
          return;
        }
        resolve({ stdout, stderr });
      },
    );
  });
}

export async function kubectl(infra: Infra, args: string[], timeoutMs = 15000): Promise<string> {
  if (!infra.kube) throw new Error(`${infra.title} has no kube context`);
  const { stdout } = await sh("kubectl", ["--context", infra.kube, ...args], { timeoutMs });
  return stdout;
}

export async function setCurrentInfra(cfg: Config, name: string): Promise<void> {
  const infra = cfg.infras[name];
  mkdirSync(stateDir, { recursive: true });
  writeFileSync(currentPath, `${name}\n`);
  // The default context for new shells and tools follows the infra; shells
  // that ran `switch` keep their own isolated KUBECONFIG.
  const steps: Promise<unknown>[] = [];
  if (infra.kube) steps.push(sh("kubectl", ["config", "use-context", infra.kube]));
  if (infra.talos) steps.push(sh("talosctl", ["config", "context", infra.talos]));
  const results = await Promise.allSettled(steps);
  const failed = results.find((r) => r.status === "rejected") as PromiseRejectedResult | undefined;
  await showToast({
    style: failed ? Toast.Style.Failure : Toast.Style.Success,
    title: failed ? `${infra.title}, partially` : `Infra: ${infra.title}`,
    message: failed ? String(failed.reason.message ?? failed.reason) : infra.kube,
  });
}

// Each terminal gets its own single-context KUBECONFIG, like kubeswitch does,
// so it keeps pointing at this infra whatever the global context becomes.
// Interactive bash keeps the user's aliases (k, kx...).
export function terminalOn(infra: Infra, command?: string) {
  const isolate = infra.kube
    ? `kc="$(mktemp -t kube-XXXXXX)"; kubectl config view --raw --flatten --minify --context=${shellQuote(infra.kube)} > "$kc" && export KUBECONFIG="$kc"`
    : "";
  const parts = [isolate, command ?? "exec bash"].filter(Boolean);
  return runInTerminal(["bash", "-ic", parts.join("; ")], { title: infra.title, hold: Boolean(command) });
}

export const shellQuote = (s: string) => `'${s.replace(/'/g, `'\\''`)}'`;

export async function failToast(err: unknown, title = "Failed") {
  await showToast({ style: Toast.Style.Failure, title, message: err instanceof Error ? err.message : String(err) });
}

export function age(since: Date): string {
  const s = Math.max(0, (Date.now() - since.getTime()) / 1000);
  if (s < 3600) return `${Math.floor(s / 60)}m`;
  if (s < 86400) return `${Math.floor(s / 3600)}h`;
  return `${Math.floor(s / 86400)}d`;
}
