import { Action, ActionPanel, Color, Icon, List } from "@vicinae/api";
import { readFileSync } from "node:fs";
import { age, expandHome } from "./lib/infra";
import { useAsync, useConfig } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type MR = {
  id: number;
  iid: number;
  title: string;
  web_url: string;
  draft: boolean;
  references: { full: string };
  author: { username: string };
  updated_at: string;
  detailed_merge_status: string;
  user_notes_count: number;
};

const statusLabel: Record<string, [string, Color]> = {
  mergeable: ["ready", Color.Green],
  ci_still_running: ["CI running", Color.Blue],
  ci_must_pass: ["CI failing", Color.Red],
  not_approved: ["needs approval", Color.Orange],
  conflict: ["conflict", Color.Red],
  need_rebase: ["rebase", Color.Orange],
  discussions_not_resolved: ["threads open", Color.Yellow],
  draft_status: ["draft", Color.SecondaryText],
};

export default function GitlabMRs() {
  const { cfg, error } = useConfig();
  const host = cfg?.gitlab?.host ?? "gitlab.com";

  const mrs = useAsync(async () => {
    // The launcher runs as a systemd service, which does not get the login
    // shell's GITLAB_TOKEN, so the sops file is read directly.
    const tokenFile = cfg?.gitlab?.tokenFile;
    const token = process.env.GITLAB_TOKEN || (tokenFile ? readFileSync(expandHome(tokenFile), "utf8").trim() : "");
    if (!token) throw new Error("no GitLab token: set gitlab.tokenFile in infra.nix");
    const get = async <T,>(path: string): Promise<T> => {
      const res = await fetch(`https://${host}/api/v4${path}`, {
        headers: { "PRIVATE-TOKEN": token },
        signal: AbortSignal.timeout(10000),
      });
      if (!res.ok) throw new Error(`GitLab answered ${res.status} for ${path.split("?")[0]}`);
      return (await res.json()) as T;
    };
    const me = await get<{ id: number }>("/user");
    const [review, mine] = await Promise.all([
      get<MR[]>(`/merge_requests?state=opened&scope=all&reviewer_id=${me.id}&per_page=50`),
      get<MR[]>(`/merge_requests?state=opened&scope=created_by_me&per_page=50`),
    ]);
    return { review, mine };
  }, [host]);

  if (!cfg) return <List>{error && <ErrorItem error={error} />}</List>;

  const item = (mr: MR) => {
    const [label, color] = statusLabel[mr.detailed_merge_status] ?? [mr.detailed_merge_status.replace(/_/g, " "), Color.SecondaryText];
    return (
      <List.Item
        key={mr.id}
        title={mr.title}
        subtitle={mr.references.full}
        icon={{ source: Icon.Code, tintColor: mr.draft ? Color.SecondaryText : color }}
        keywords={[mr.author.username, mr.references.full]}
        accessories={[
          { tag: { value: label, color } },
          ...(mr.user_notes_count > 0 ? [{ text: `${mr.user_notes_count} notes` }] : []),
          { text: age(new Date(mr.updated_at)) },
        ]}
        actions={
          <ActionPanel>
            <Action.OpenInBrowser title="Open Merge Request" url={mr.web_url} />
            <Action.OpenInBrowser title="Open Pipelines" url={`${mr.web_url}/pipelines`} />
            <Action.OpenInBrowser title="Open Diff" url={`${mr.web_url}/diffs`} />
            <Action.CopyToClipboard title="Copy Reference" content={mr.references.full} />
            <Action title="Reload" icon={Icon.ArrowClockwise} shortcut={{ modifiers: ["ctrl"], key: "r" }} onAction={mrs.reload} />
          </ActionPanel>
        }
      />
    );
  };

  return (
    <List isLoading={mrs.isLoading} searchBarPlaceholder={`Merge requests on ${host}`}>
      {mrs.error && <ErrorItem error={mrs.error} onRetry={mrs.reload} />}
      <List.Section title="To review" subtitle={mrs.data ? String(mrs.data.review.length) : undefined}>
        {mrs.data?.review.map(item)}
      </List.Section>
      <List.Section title="Mine" subtitle={mrs.data ? String(mrs.data.mine.length) : undefined}>
        {mrs.data?.mine.map(item)}
      </List.Section>
    </List>
  );
}
