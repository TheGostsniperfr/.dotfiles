import { Action, ActionPanel, Icon, List } from "@vicinae/api";
import { readFileSync } from "node:fs";
import { useState } from "react";
import { expandHome } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Hit = { uid: string; title: string; url: string; folderTitle?: string; tags: string[]; type: string };

// With a token file the Grafana search API lists dashboards; without one the
// query is handed to Grafana's own search page.
export default function GrafanaDashboards() {
  const { infra, error } = useActive();
  const [query, setQuery] = useState("");
  const base = infra?.links.grafana;
  const tokenFile = infra?.grafanaTokenFile;

  const hits = useAsync(async () => {
    if (!base || !tokenFile) return undefined;
    const token = readFileSync(expandHome(tokenFile), "utf8").trim();
    const res = await fetch(`${base}/api/search?type=dash-db&limit=200&query=${encodeURIComponent(query)}`, {
      headers: { Authorization: `Bearer ${token}` },
      signal: AbortSignal.timeout(10000),
    });
    if (!res.ok) throw new Error(`Grafana answered ${res.status}`);
    return (await res.json()) as Hit[];
  }, [base, query]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  if (!base) {
    return (
      <List>
        <List.Item title={`No Grafana declared for ${infra.title}`} subtitle="links.grafana in infra.nix" icon={Icon.Info01} />
      </List>
    );
  }

  const searchUrl = `${base}/dashboards?query=${encodeURIComponent(query)}`;
  return (
    <List isLoading={hits.isLoading} filtering={false} onSearchTextChange={setQuery} throttle searchBarPlaceholder={`Dashboards on ${infra.title}`}>
      {hits.error && <ErrorItem error={hits.error} onRetry={hits.reload} />}
      {hits.data?.map((h) => (
        <List.Item
          key={h.uid}
          title={h.title}
          subtitle={h.folderTitle}
          icon={Icon.LineChart}
          accessories={h.tags.slice(0, 3).map((t) => ({ tag: t }))}
          actions={
            <ActionPanel>
              <Action.OpenInBrowser title="Open Dashboard" url={`${base}${h.url}`} />
              <Action.OpenInBrowser title="Open Last 24 Hours" url={`${base}${h.url}?from=now-24h&to=now`} />
              <Action.CopyToClipboard title="Copy URL" content={`${base}${h.url}`} />
            </ActionPanel>
          }
        />
      ))}
      {!hits.data && (
        <List.Item
          title={query ? `Search "${query}" in Grafana` : "Open Grafana dashboards"}
          subtitle={new URL(base).host}
          icon={Icon.MagnifyingGlass}
          actions={
            <ActionPanel>
              <Action.OpenInBrowser title="Open in Grafana" url={searchUrl} />
            </ActionPanel>
          }
        />
      )}
    </List>
  );
}
