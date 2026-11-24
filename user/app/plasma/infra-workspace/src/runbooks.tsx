import { Action, ActionPanel, Detail, Icon, List } from "@vicinae/api";
import { readdirSync, readFileSync, statSync } from "node:fs";
import { basename, join, relative } from "node:path";
import { useMemo } from "react";
import { expandHome } from "./lib/infra";
import { useConfig } from "./lib/hooks";
import { ErrorItem } from "./lib/views";

type Doc = { path: string; dir: string; title: string; body: string };

function walk(dir: string, depth = 0): string[] {
  if (depth > 4) return [];
  let entries: string[];
  try {
    entries = readdirSync(dir);
  } catch {
    return [];
  }
  return entries.flatMap((e) => {
    if (e.startsWith(".") || e === "node_modules") return [];
    const p = join(dir, e);
    const st = statSync(p);
    if (st.isDirectory()) return walk(p, depth + 1);
    return /\.(md|markdown)$/i.test(e) ? [p] : [];
  });
}

function loadDocs(dirs: string[]): Doc[] {
  return dirs.flatMap((d) => {
    const root = expandHome(d);
    return walk(root).map((path) => {
      const body = readFileSync(path, "utf8");
      const heading = body.match(/^#\s+(.+)$/m)?.[1];
      return { path, dir: relative(root, path), title: heading ?? basename(path), body };
    });
  });
}

export default function Runbooks() {
  const { cfg, error } = useConfig();
  const docs = useMemo(() => loadDocs(cfg?.runbooks?.dirs ?? []), [cfg]);
  if (!cfg) return <List>{error && <ErrorItem error={error} />}</List>;
  const hub = cfg.runbooks?.hubUrl;

  return (
    <List searchBarPlaceholder="Search runbooks">
      {hub && (
        <List.Item
          title="SRE Research Hub"
          subtitle="Notion"
          icon={Icon.BookAntique}
          actions={
            <ActionPanel>
              <Action.OpenInBrowser title="Open Hub" url={hub} />
            </ActionPanel>
          }
        />
      )}
      {docs.length === 0 && <List.Item title="No runbook found" subtitle={(cfg.runbooks?.dirs ?? []).join(", ") || "runbooks.dirs in infra.nix"} icon={Icon.Info01} />}
      {docs.map((d) => (
        <List.Item
          key={d.path}
          title={d.title}
          subtitle={d.dir}
          icon={Icon.Book}
          keywords={d.body.slice(0, 4000).split(/\W+/).filter((w) => w.length > 3)}
          actions={
            <ActionPanel>
              <Action.Push title="Read" icon={Icon.Eye} target={<Detail markdown={d.body} navigationTitle={d.title} />} />
              <Action.Open title="Open in Editor" target={d.path} />
              <Action.CopyToClipboard title="Copy Path" content={d.path} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
