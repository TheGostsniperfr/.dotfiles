import { Action, ActionPanel, closeMainWindow, Icon, List, open } from "@vicinae/api";
import { useState } from "react";
import { Config, currentInfraName, envTag, failToast, Infra, serviceIcon, setCurrentInfra, terminalOn } from "./lib/infra";
import { useConfig } from "./lib/hooks";
import { ErrorItem } from "./lib/views";
import SwitchInfra from "./switch-infra";

const label = (service: string) => service.charAt(0).toUpperCase() + service.slice(1);

function LinkItem({ cfg, name, infra, service, url, isActive, onActivate }: {
  cfg: Config; name: string; infra: Infra; service: string; url: string; isActive: boolean; onActivate: () => void;
}) {
  const openOn = async () => {
    if (!isActive) await setCurrentInfra(cfg, name);
    await open(url);
    await closeMainWindow();
  };
  return (
    <List.Item
      id={`${name}/${service}`}
      title={label(service)}
      subtitle={new URL(url).host}
      icon={serviceIcon(service)}
      keywords={[service, name, infra.title, infra.env]}
      accessories={isActive ? [envTag(infra)] : [{ text: infra.title }, envTag(infra)]}
      actions={
        <ActionPanel>
          <Action title={isActive ? "Open" : `Open and Switch to ${infra.title}`} icon={Icon.Globe01} onAction={openOn} />
          {!isActive && <Action.OpenInBrowser title="Open Without Switching" url={url} />}
          <Action.CopyToClipboard title="Copy URL" content={url} />
          {!isActive && (
            <Action
              title={`Make ${infra.title} Active`}
              icon={Icon.Switch}
              shortcut={{ modifiers: ["ctrl"], key: "i" }}
              onAction={() => setCurrentInfra(cfg, name).then(onActivate, failToast)}
            />
          )}
          <Action
            title="Terminal on This Infra"
            icon={Icon.Terminal}
            shortcut={{ modifiers: ["ctrl"], key: "t" }}
            onAction={() => terminalOn(infra).catch(failToast)}
          />
          <Action.Push title="Switch Infra…" icon={Icon.Shuffle} target={<SwitchInfra />} shortcut={{ modifiers: ["ctrl"], key: "s" }} />
        </ActionPanel>
      }
    />
  );
}

export default function InfraLinks() {
  const { cfg, error } = useConfig();
  const [, refresh] = useState(0);
  if (!cfg) return <List>{error && <ErrorItem error={error} />}</List>;

  const active = currentInfraName(cfg);
  const order = [active, ...Object.keys(cfg.infras).filter((n) => n !== active)].filter(Boolean) as string[];

  return (
    <List searchBarPlaceholder="grafana, argocd, vault…">
      {order.map((name) => {
        const infra = cfg.infras[name];
        const links = Object.entries(infra.links);
        const isActive = name === active;
        return (
          <List.Section key={name} title={isActive ? `${infra.title} · active` : infra.title} subtitle={infra.kube}>
            {links.length === 0 && isActive && (
              <List.Item title="No links declared" subtitle="Add them in infra.nix" icon={Icon.Info01} />
            )}
            {links.map(([service, url]) => (
              <LinkItem
                key={service}
                cfg={cfg}
                name={name}
                infra={infra}
                service={service}
                url={url}
                isActive={isActive}
                onActivate={() => refresh((t) => t + 1)}
              />
            ))}
          </List.Section>
        );
      })}
    </List>
  );
}
