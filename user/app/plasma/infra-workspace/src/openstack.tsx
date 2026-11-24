import { Action, ActionPanel, Color, Icon, List } from "@vicinae/api";
import { failToast, sh, shellQuote, terminalOn } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Server = { ID: string; Name: string; Status: string; Networks: Record<string, string[]> | string; Flavor: string; Image: string };

const statusColor: Record<string, Color> = { ACTIVE: Color.Green, BUILD: Color.Blue, SHUTOFF: Color.SecondaryText, ERROR: Color.Red };

const ips = (n: Server["Networks"]) =>
  typeof n === "string" ? n : Object.entries(n).map(([net, addrs]) => `${net}: ${addrs.join(", ")}`).join("  ");

export default function OpenstackServers() {
  const { infra, error } = useActive();
  const cloud = infra?.openstackCloud;
  const servers = useAsync(async () => {
    if (!cloud) return [];
    const { stdout } = await sh("openstack", ["--os-cloud", cloud, "server", "list", "-f", "json", "--long"], { timeoutMs: 30000 });
    return JSON.parse(stdout) as Server[];
  }, [cloud]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  if (!cloud) {
    return (
      <List>
        <List.Item title={`No OpenStack cloud for ${infra.title}`} subtitle="openstackCloud in infra.nix (name from clouds.yaml)" icon={Icon.Info01} />
      </List>
    );
  }

  return (
    <List isLoading={servers.isLoading} searchBarPlaceholder={`Servers in ${cloud}`}>
      {servers.error && <ErrorItem error={servers.error} onRetry={servers.reload} />}
      {servers.data?.map((s) => (
        <List.Item
          key={s.ID}
          title={s.Name}
          subtitle={ips(s.Networks)}
          icon={{ source: Icon.Cloud, tintColor: statusColor[s.Status] ?? Color.Orange }}
          keywords={[s.ID, s.Flavor, ips(s.Networks)]}
          accessories={[{ text: s.Flavor }, { tag: { value: s.Status, color: statusColor[s.Status] ?? Color.Orange } }]}
          actions={
            <ActionPanel>
              <Action
                title="Show Details"
                icon={Icon.Info01}
                onAction={() => terminalOn(infra, `openstack --os-cloud ${shellQuote(cloud)} server show ${s.ID} | less -R`).catch(failToast)}
              />
              <Action
                title="Console Log"
                icon={Icon.Terminal}
                onAction={() => terminalOn(infra, `openstack --os-cloud ${shellQuote(cloud)} console log show --lines 200 ${s.ID} | less -R`).catch(failToast)}
              />
              {infra.links.openstack && <Action.OpenInBrowser title="Open Horizon" url={`${infra.links.openstack}/project/instances/${s.ID}/`} />}
              <Action.CopyToClipboard title="Copy ID" content={s.ID} />
              <Action.CopyToClipboard title="Copy Addresses" content={ips(s.Networks)} />
              <Action title="Reload" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["ctrl"], key: "r" }} onAction={servers.reload} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
