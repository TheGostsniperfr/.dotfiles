import { Action, ActionPanel, Icon, List } from "@vicinae/api";

export function ErrorItem({ error, onRetry }: { error: Error; onRetry?: () => void }) {
  return (
    <List.Item
      title="Unavailable"
      subtitle={error.message}
      icon={Icon.Warning}
      actions={
        <ActionPanel>
          {onRetry && <Action title="Retry" icon={Icon.ArrowClockwise} onAction={onRetry} />}
          <Action.CopyToClipboard title="Copy Error" content={error.message} />
        </ActionPanel>
      }
    />
  );
}
