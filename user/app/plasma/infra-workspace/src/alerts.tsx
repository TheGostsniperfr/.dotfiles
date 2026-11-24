import { Action, ActionPanel, Color, Icon, List } from "@vicinae/api";
import { age, kubectl } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Alert = {
  fingerprint: string;
  labels: Record<string, string>;
  annotations: Record<string, string>;
  startsAt: string;
  generatorURL?: string;
  status: { state: string; silencedBy: string[]; inhibitedBy: string[] };
};

const severityColor: Record<string, Color> = { critical: Color.Red, warning: Color.Orange, info: Color.Blue };
const severityRank: Record<string, number> = { critical: 0, warning: 1, info: 2 };

export default function FiringAlerts() {
  const { infra, error } = useActive();
  const am = infra?.alertmanager ?? { namespace: "monitoring", service: "alertmanager-operated", port: 9093 };

  // Through the API server proxy: no port-forward and no extra credentials.
  const alerts = useAsync(async () => {
    if (!infra) throw error ?? new Error("no active infra");
    const path = `/api/v1/namespaces/${am.namespace}/services/${am.service}:${am.port}/proxy/api/v2/alerts?active=true&silenced=false&inhibited=false`;
    const out = await kubectl(infra, ["get", "--raw", path], 15000);
    return (JSON.parse(out) as Alert[])
      .filter((a) => a.labels.alertname !== "Watchdog" && a.labels.alertname !== "InfoInhibitor")
      .sort((a, b) => (severityRank[a.labels.severity] ?? 9) - (severityRank[b.labels.severity] ?? 9));
  }, [infra?.kube]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;

  return (
    <List isLoading={alerts.isLoading} searchBarPlaceholder={`Alerts on ${infra.title}`}>
      {alerts.error && <ErrorItem error={alerts.error} onRetry={alerts.reload} />}
      {alerts.data?.length === 0 && <List.Item title="No firing alert" icon={{ source: Icon.CheckCircle, tintColor: Color.Green }} />}
      {alerts.data?.map((a) => {
        const sev = a.labels.severity ?? "none";
        const where = a.labels.namespace ?? a.labels.instance ?? a.labels.job ?? "";
        return (
          <List.Item
            key={a.fingerprint}
            title={a.labels.alertname}
            subtitle={a.annotations.summary ?? where}
            icon={{ source: Icon.Bell, tintColor: severityColor[sev] ?? Color.SecondaryText }}
            keywords={Object.values(a.labels)}
            accessories={[
              { tag: { value: sev, color: severityColor[sev] ?? Color.SecondaryText } },
              ...(where ? [{ text: where }] : []),
              { text: age(new Date(a.startsAt)) },
            ]}
            actions={
              <ActionPanel>
                {a.annotations.runbook_url && <Action.OpenInBrowser title="Open Runbook" url={a.annotations.runbook_url} />}
                {a.generatorURL && <Action.OpenInBrowser title="Open Query" url={a.generatorURL} />}
                {infra.links.alertmanager && (
                  <Action.OpenInBrowser
                    title="Open in Alertmanager"
                    url={`${infra.links.alertmanager}/#/alerts?filter=${encodeURIComponent(`{alertname="${a.labels.alertname}"}`)}`}
                  />
                )}
                <Action.CopyToClipboard title="Copy Labels" content={JSON.stringify(a.labels, null, 2)} />
                <Action title="Reload" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["ctrl"], key: "r" }} onAction={alerts.reload} />
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
