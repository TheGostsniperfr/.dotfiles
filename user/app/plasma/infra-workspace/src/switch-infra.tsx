import { Action, ActionPanel, Icon, List, popToRoot } from "@vicinae/api";
import { useState } from "react";
import { currentInfraName, envTag, failToast, setCurrentInfra, terminalOn } from "./lib/infra";
import { useConfig } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

export default function SwitchInfra() {
  const { cfg, error } = useConfig();
  const [active, setActive] = useState(() => (cfg ? currentInfraName(cfg) : undefined));
  if (!cfg) return <List>{error && <ErrorItem error={error} />}</List>;

  return (
    <List searchBarPlaceholder="Switch infra">
      {Object.entries(cfg.infras).map(([name, infra]) => (
        <List.Item
          key={name}
          title={infra.title}
          subtitle={[infra.kube, infra.talos && `talos: ${infra.talos}`].filter(Boolean).join("  ·  ")}
          icon={name === active ? Icon.CheckCircle : Icon.Circle}
          keywords={[name, infra.env]}
          accessories={[envTag(infra), { text: `${Object.keys(infra.links).length} links` }]}
          actions={
            <ActionPanel>
              <Action
                title="Make Active"
                icon={Icon.Switch}
                onAction={async () => {
                  try {
                    await setCurrentInfra(cfg, name);
                    setActive(name);
                    await popToRoot();
                  } catch (err) {
                    await failToast(err);
                  }
                }}
              />
              <Action title="Terminal on This Infra" icon={Icon.Terminal} onAction={() => terminalOn(infra).catch(failToast)} />
              {infra.kube && <Action.CopyToClipboard title="Copy Kube Context" content={infra.kube} />}
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
