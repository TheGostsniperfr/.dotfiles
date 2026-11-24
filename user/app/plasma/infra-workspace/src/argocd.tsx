import { Action, ActionPanel, Alert, Color, confirmAlert, Icon, List, showToast, Toast } from "@vicinae/api";
import { failToast, kubectl } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

// Reads Application CRs through the Kubernetes API, so it reuses the kube
// auth of the infra and needs no `argocd login`.
type App = {
  namespace: string;
  name: string;
  project: string;
  sync: string;
  health: string;
  repo?: string;
  revision?: string;
  operation?: string;
};

type AppJson = {
  metadata: { namespace: string; name: string };
  spec: { project: string; source?: { repoURL: string; targetRevision?: string }; sources?: { repoURL: string }[] };
  status?: { sync?: { status?: string; revision?: string }; health?: { status?: string }; operationState?: { phase?: string } };
};

const toApp = (a: AppJson): App => ({
  namespace: a.metadata.namespace,
  name: a.metadata.name,
  project: a.spec.project,
  sync: a.status?.sync?.status ?? "Unknown",
  health: a.status?.health?.status ?? "Unknown",
  repo: a.spec.source?.repoURL ?? a.spec.sources?.[0]?.repoURL,
  revision: a.status?.sync?.revision?.slice(0, 8),
  operation: a.status?.operationState?.phase,
});

const healthColor: Record<string, Color> = {
  Healthy: Color.Green,
  Progressing: Color.Blue,
  Suspended: Color.Purple,
  Degraded: Color.Red,
  Missing: Color.Orange,
};

const needsAttention = (a: App) => a.sync !== "Synced" || a.health !== "Healthy";

export default function ArgoApps() {
  const { infra, error } = useActive();
  const ns = infra?.argocdNamespace ?? "argocd";
  const apps = useAsync(async () => {
    if (!infra) throw error ?? new Error("no active infra");
    const out = await kubectl(infra, ["get", "applications.argoproj.io", "-n", ns, "-o", "json"], 20000);
    return (JSON.parse(out).items as AppJson[]).map(toApp).sort((a, b) => Number(needsAttention(b)) - Number(needsAttention(a)));
  }, [infra?.kube]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  const ui = infra.links.argocd;

  const patch = async (app: App, body: object, done: string) => {
    try {
      await kubectl(infra, ["-n", app.namespace, "patch", "application", app.name, "--type", "merge", "-p", JSON.stringify(body)]);
      await showToast({ style: Toast.Style.Success, title: done, message: app.name });
      apps.reload();
    } catch (err) {
      await failToast(err);
    }
  };

  const sync = async (app: App) => {
    const ok = await confirmAlert({
      title: `Sync ${app.name} on ${infra.title}?`,
      message: infra.env === "prod" ? "This is a production infra." : undefined,
      primaryAction: { title: "Sync", style: Alert.ActionStyle.Destructive },
    });
    if (ok) await patch(app, { operation: { initiatedBy: { username: "vicinae" }, sync: { prune: false } } }, "Sync requested");
  };

  return (
    <List isLoading={apps.isLoading} searchBarPlaceholder={`ArgoCD apps on ${infra.title}`}>
      {apps.error && <ErrorItem error={apps.error} onRetry={apps.reload} />}
      {apps.data?.map((app) => (
        <List.Item
          key={`${app.namespace}/${app.name}`}
          title={app.name}
          subtitle={app.project}
          icon={{ source: Icon.CircleFilled, tintColor: healthColor[app.health] ?? Color.SecondaryText }}
          keywords={[app.project, app.sync, app.health, app.repo ?? ""]}
          accessories={[
            ...(app.operation === "Running" ? [{ tag: { value: "syncing", color: Color.Blue } }] : []),
            { tag: { value: app.sync, color: app.sync === "Synced" ? Color.Green : Color.Orange } },
            { tag: { value: app.health, color: healthColor[app.health] ?? Color.SecondaryText } },
            ...(app.revision ? [{ text: app.revision }] : []),
          ]}
          actions={
            <ActionPanel>
              {ui && <Action.OpenInBrowser title="Open in ArgoCD" url={`${ui}/applications/${app.namespace}/${app.name}`} />}
              <Action
                title="Hard Refresh"
                icon={Icon.ArrowClockwise}
                shortcut={{ modifiers: ["ctrl"], key: "r" }}
                onAction={() => patch(app, { metadata: { annotations: { "argocd.argoproj.io/refresh": "hard" } } }, "Refresh requested")}
              />
              <Action title="Sync" icon={Icon.Repeat} shortcut={{ modifiers: ["ctrl", "shift"], key: "s" }} onAction={() => sync(app)} />
              {app.repo && <Action.OpenInBrowser title="Open Source Repository" url={app.repo.replace(/\.git$/, "")} />}
              <Action.CopyToClipboard title="Copy Name" content={app.name} />
              <Action title="Reload List" icon={Icon.ArrowClockwise} onAction={apps.reload} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
