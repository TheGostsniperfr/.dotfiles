import { Action, ActionPanel, Icon, List } from "@vicinae/api";
import { failToast, sh, shellQuote, terminalOn } from "./lib/infra";
import { useActive, useAsync } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Target = { id: string; name: string; type: string; scope?: { name: string }; description?: string };

// Only lists targets with an existing Boundary session; authentication itself
// happens in a terminal so the OIDC browser flow and token stay with the CLI.
export default function BoundaryVault() {
  const { infra, error } = useActive();
  const addr = infra?.boundary?.addr;
  const targets = useAsync(async () => {
    if (!addr) return [];
    const { stdout } = await sh("boundary", ["targets", "list", "-recursive", "-format", "json"], {
      env: { BOUNDARY_ADDR: addr },
      timeoutMs: 15000,
    });
    return (JSON.parse(stdout).items ?? []) as Target[];
  }, [addr]);

  if (!infra) return <List>{error && <ErrorItem error={error} />}</List>;
  const vault = infra.vault?.addr;

  return (
    <List isLoading={targets.isLoading} searchBarPlaceholder={`Access to ${infra.title}`}>
      <List.Section title="Sessions">
        {addr && (
          <List.Item
            title="Boundary: authenticate"
            subtitle={addr}
            icon={Icon.Network}
            actions={
              <ActionPanel>
                <Action
                  title="Authenticate in Terminal"
                  onAction={() => terminalOn(infra, `BOUNDARY_ADDR=${shellQuote(addr)} boundary authenticate`).catch(failToast)}
                />
              </ActionPanel>
            }
          />
        )}
        {vault && (
          <List.Item
            title="Vault: OIDC login"
            subtitle={vault}
            icon={Icon.Lock}
            actions={
              <ActionPanel>
                <Action title="Login in Terminal" onAction={() => terminalOn(infra, `VAULT_ADDR=${shellQuote(vault)} vault login -method=oidc`).catch(failToast)} />
                {infra.links.vault && <Action.OpenInBrowser title="Open Vault UI" url={infra.links.vault} />}
                <Action.CopyToClipboard title="Copy export VAULT_ADDR" content={`export VAULT_ADDR=${vault}`} />
              </ActionPanel>
            }
          />
        )}
        {!addr && !vault && <List.Item title={`No Boundary or Vault for ${infra.title}`} subtitle="boundary.addr / vault.addr in infra.nix" icon={Icon.Info01} />}
      </List.Section>
      <List.Section title="Boundary targets">
        {targets.error && <ErrorItem error={targets.error} onRetry={targets.reload} />}
        {targets.data?.map((t) => (
          <List.Item
            key={t.id}
            title={t.name}
            subtitle={t.description ?? t.id}
            icon={Icon.Plug}
            accessories={[{ tag: t.type }, ...(t.scope ? [{ text: t.scope.name }] : [])]}
            actions={
              <ActionPanel>
                <Action
                  title={t.type === "ssh" ? "Connect (ssh)" : "Connect"}
                  icon={Icon.Terminal}
                  onAction={() =>
                    terminalOn(infra, `BOUNDARY_ADDR=${shellQuote(addr ?? "")} boundary connect${t.type === "ssh" ? " ssh" : ""} -target-id ${t.id}`).catch(failToast)
                  }
                />
                <Action.CopyToClipboard title="Copy Target ID" content={t.id} />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
