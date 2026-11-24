import { Action, ActionPanel, Color, Icon, List } from "@vicinae/api";
import { failToast, kubectl, shellQuote, terminalOn } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Node = { name: string; ip?: string; ready: boolean; roles: string[]; version: string; os: string };

type NodeJson = {
  metadata: { name: string; labels: Record<string, string> };
  status: {
    addresses: { type: string; address: string }[];
    conditions: { type: string; status: string }[];
    nodeInfo: { kubeletVersion: string; osImage: string };
  };
};

// Node list comes from Kubernetes (fast, no talosconfig round trip); talosctl
// is used for the per-node actions.
export default function TalosNodes() {
  const { infra, error } = useActive();
  const nodes = useAsync(async () => {
    if (!infra) throw error ?? new Error("no active infra");
    const out = await kubectl(infra, ["get", "nodes", "-o", "json"]);
    return (JSON.parse(out).items as NodeJson[]).map(
      (n): Node => ({
        name: n.metadata.name,
        ip: n.status.addresses.find((a) => a.type === "InternalIP")?.address,
        ready: n.status.conditions.some((c) => c.type === "Ready" && c.status === "True"),
        roles: Object.keys(n.metadata.labels)
          .filter((l) => l.startsWith("node-role.kubernetes.io/"))
          .map((l) => l.split("/")[1]),
        version: n.status.nodeInfo.kubeletVersion,
        os: n.status.nodeInfo.osImage,
      }),
    );
  }, [infra?.kube]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  const talos = infra.talos ? `--context ${shellQuote(infra.talos)}` : "";

  return (
    <List isLoading={nodes.isLoading} searchBarPlaceholder={`Nodes on ${infra.title}`}>
      {nodes.error && <ErrorItem error={nodes.error} onRetry={nodes.reload} />}
      {!infra.talos && <List.Item title="No talos context declared" subtitle="talos in infra.nix enables the talosctl actions" icon={Icon.Info01} />}
      {nodes.data?.map((n) => (
        <List.Item
          key={n.name}
          title={n.name}
          subtitle={n.ip}
          icon={{ source: Icon.HardDrive, tintColor: n.ready ? Color.Green : Color.Red }}
          keywords={[...n.roles, n.os]}
          accessories={[
            ...n.roles.map((r) => ({ tag: r })),
            { text: n.version },
            { tag: { value: n.ready ? "Ready" : "NotReady", color: n.ready ? Color.Green : Color.Red } },
          ]}
          actions={
            <ActionPanel>
              {infra.talos && n.ip && (
                <>
                  <Action title="Talos Dashboard" icon={Icon.Gauge} onAction={() => terminalOn(infra, `talosctl ${talos} -n ${n.ip} dashboard`).catch(failToast)} />
                  <Action title="Health Check" icon={Icon.Heartbeat} onAction={() => terminalOn(infra, `talosctl ${talos} -n ${n.ip} health`).catch(failToast)} />
                  <Action title="Services" icon={Icon.Layers} onAction={() => terminalOn(infra, `talosctl ${talos} -n ${n.ip} services`).catch(failToast)} />
                  <Action title="Kernel Logs" icon={Icon.Terminal} onAction={() => terminalOn(infra, `talosctl ${talos} -n ${n.ip} dmesg -f`).catch(failToast)} />
                </>
              )}
              {n.ip && <Action.CopyToClipboard title="Copy IP" content={n.ip} />}
              <Action title="Reload" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["ctrl"], key: "r" }} onAction={nodes.reload} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
