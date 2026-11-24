import { Action, ActionPanel, Color, Icon, List } from "@vicinae/api";
import { age, failToast, kubectl, shellQuote, terminalOn } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Pod = {
  namespace: string;
  name: string;
  phase: string;
  reason?: string;
  ready: string;
  restarts: number;
  node?: string;
  created: Date;
  containers: string[];
};

type PodJson = {
  metadata: { namespace: string; name: string; creationTimestamp: string; deletionTimestamp?: string };
  spec: { nodeName?: string; containers: { name: string }[] };
  status: {
    phase: string;
    reason?: string;
    containerStatuses?: { ready: boolean; restartCount: number; state: { waiting?: { reason?: string }; terminated?: { reason?: string } } }[];
  };
};

function toPod(p: PodJson): Pod {
  const cs = p.status.containerStatuses ?? [];
  const waiting = cs.map((c) => c.state.waiting?.reason ?? c.state.terminated?.reason).find(Boolean);
  return {
    namespace: p.metadata.namespace,
    name: p.metadata.name,
    phase: p.metadata.deletionTimestamp ? "Terminating" : p.status.phase,
    reason: waiting ?? p.status.reason,
    ready: `${cs.filter((c) => c.ready).length}/${p.spec.containers.length}`,
    restarts: cs.reduce((n, c) => n + c.restartCount, 0),
    node: p.spec.nodeName,
    created: new Date(p.metadata.creationTimestamp),
    containers: p.spec.containers.map((c) => c.name),
  };
}

const healthy = (p: Pod) => (p.phase === "Running" && !p.reason && p.ready.split("/")[0] === p.ready.split("/")[1]) || p.phase === "Succeeded";

const statusColor = (p: Pod) => (healthy(p) ? Color.Green : p.phase === "Pending" || p.phase === "Terminating" ? Color.Yellow : Color.Red);

export default function KubePods() {
  const { infra, error } = useActive();
  const pods = useAsync(async () => {
    if (!infra) throw error ?? new Error("no active infra");
    const out = await kubectl(infra, ["get", "pods", "-A", "-o", "json"], 20000);
    return (JSON.parse(out).items as PodJson[]).map(toPod).sort((a, b) => Number(healthy(a)) - Number(healthy(b)));
  }, [infra?.kube]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  const ctx = `--context ${shellQuote(infra.kube ?? "")}`;
  const unhealthy = pods.data?.filter((p) => !healthy(p)) ?? [];
  const rest = pods.data?.filter(healthy) ?? [];

  const item = (p: Pod) => (
    <List.Item
      key={`${p.namespace}/${p.name}`}
      title={p.name}
      subtitle={p.namespace}
      icon={{ source: Icon.CircleFilled, tintColor: statusColor(p) }}
      keywords={[p.namespace, p.phase, p.reason ?? "", p.node ?? ""]}
      accessories={[
        ...(p.reason ? [{ tag: { value: p.reason, color: Color.Red } }] : []),
        { text: p.ready },
        ...(p.restarts > 0 ? [{ text: { value: `↻ ${p.restarts}`, color: Color.Orange } }] : []),
        { text: age(p.created) },
      ]}
      actions={
        <ActionPanel>
          <Action
            title="Follow Logs"
            icon={Icon.Terminal}
            onAction={() => terminalOn(infra, `kubectl ${ctx} logs -f --tail=300 --all-containers -n ${p.namespace} ${p.name}`).catch(failToast)}
          />
          <Action
            title="Shell Into Pod"
            icon={Icon.Code}
            onAction={() => terminalOn(infra, `kubectl ${ctx} exec -it -n ${p.namespace} ${p.name} -- sh -c 'command -v bash >/dev/null && exec bash || exec sh'`).catch(failToast)}
          />
          <Action
            title="Describe"
            icon={Icon.Info01}
            shortcut={{ modifiers: ["ctrl"], key: "d" }}
            onAction={() => terminalOn(infra, `kubectl ${ctx} describe pod -n ${p.namespace} ${p.name} | less -R`).catch(failToast)}
          />
          <Action.CopyToClipboard title="Copy Name" content={p.name} />
          <Action.CopyToClipboard title="Copy kubectl Target" content={`-n ${p.namespace} ${p.name}`} />
          <Action title="Reload" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["ctrl"], key: "r" }} onAction={pods.reload} />
          <Action title="Open ktop" icon={Icon.Gauge} onAction={() => terminalOn(infra, `ktop ${ctx}`).catch(failToast)} />
        </ActionPanel>
      }
    />
  );

  return (
    <List isLoading={pods.isLoading} searchBarPlaceholder={`Pods on ${infra.title}`}>
      {pods.error && <ErrorItem error={pods.error} onRetry={pods.reload} />}
      <List.Section title="Needs attention" subtitle={String(unhealthy.length)}>
        {unhealthy.map(item)}
      </List.Section>
      <List.Section title="Healthy" subtitle={String(rest.length)}>
        {rest.map(item)}
      </List.Section>
    </List>
  );
}
