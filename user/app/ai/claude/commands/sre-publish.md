# /sre-publish — Phase 6: Notion Publication

$ARGUMENTS — topic-slug [article|livrable|runbook|all]

Publish generated documents to the SRE Research Hub in Notion.
Uses the Notion MCP tools directly (no agent needed).

---

## Steps

1. Read `brief.yaml`, `meta.yaml`, and the generated doc files.

2. Determine which docs to publish:
   - From `$ARGUMENTS` second word, or publish all that exist and haven't been published yet.

3. **Find the SRE Research Hub in Notion:**
   - Search Notion for "SRE Research Hub"
   - Find the Research Projects database and Documents database under it
   - If not found: tell the user "SRE Research Hub not found in Notion. Create it first by running `/sre-research new` on any project — it will be created automatically." Then stop.

4. **Update or create the Research Project record:**
   - Search the Research Projects database for an entry matching `topic_slug`
   - If not found: create a new entry with:
     - Name: `<topic_name>` (from brief.yaml)
     - Slug: `<topic_slug>`
     - Status: Published
     - Tags: (infer from topic)
     - Created: (from meta.yaml)
   - If found: update Status to Published

5. **For each document to publish:**
   - Read the full file content (article.md / livrable.md / runbook.md)
   - Create a new page in the Documents database with:
     - Title: `<doc type>: <topic_name>` (e.g., "Research Article: Kueue GPU Job Scheduling")
     - Type: Research Article / Livrable / Runbook
     - Status: Draft (user reviews and sets to Published manually)
     - Version: 1.0
   - Convert the markdown content to Notion page content
   - Important: Mermaid code blocks → keep as code blocks (Notion renders them)
   - Important: Tables → use Notion table syntax

6. **Save Notion URLs** to `meta.yaml.notion_urls`:
   ```yaml
   notion_urls:
     project: <research project page URL>
     article: <article page URL>
     livrable: <livrable page URL>
     runbook: <runbook page URL>
   ```

7. Update `meta.yaml`: `phase: published`, `last_updated: <today>`.

8. Print all Notion URLs. Tell the user:
   ```
   Published to Notion:
   - Research Project: <URL>
   - Article: <URL>
   - Livrable: <URL>
   - Runbook: <URL>

   Documents are set to "Draft" status — review and set to "Published" in Notion when ready.
   ```

---

## Note on first-time setup

If the SRE Research Hub doesn't exist yet, create it:

1. Create "SRE Research Hub" page under "Infra" in Notion
2. Create "Research Projects" database with schema:
   - Name: TITLE
   - Slug: RICH_TEXT
   - Status: SELECT('Brief', 'Landscape', 'Deep Dive', 'Lab', 'Synthesis', 'Writing', 'Published')
   - Tags: MULTI_SELECT('Networking', 'Scheduling', 'Security', 'CI-CD', 'Storage', 'Observability', 'Runtime')
   - Priority: SELECT('High', 'Medium', 'Low')
   - K8s Version Range: RICH_TEXT
   - Cluster Count: NUMBER
   - Created: DATE
3. Create "Documents" database with schema:
   - Name: TITLE
   - Type: SELECT('Research Article', 'Livrable', 'Runbook')
   - Status: SELECT('Draft', 'Review', 'Published')
   - Version: RICH_TEXT
   - Published Date: DATE
4. Create "Implementation Evaluations" database with schema:
   - Name: TITLE
   - Implementation: RICH_TEXT
   - Lab Tested: CHECKBOX
   - Lab Status: SELECT('Not Started', 'In Progress', 'Passed', 'Partial', 'Failed')
   - Score Performance: NUMBER
   - Score Complexity: NUMBER
   - Score Security: NUMBER
   - Score Documentation: NUMBER
   - Score Maturity: NUMBER
   - Score Features: NUMBER
   - Score Migration: NUMBER
   - Weighted Total: NUMBER
   - Verdict: SELECT('Recommended', 'Viable', 'Not Recommended', 'Blocked')
