---
name: teams-to-confluence
description: >
  Transfers information from Microsoft Teams chats into Confluence pages for persistent, shared documentation.
  Triggers on requests to capture, extract, or migrate content from a Teams chat into Confluence, such as
  "save this Teams chat to Confluence", "create a Confluence page from my Teams chat", or "move chat info
  to Confluence". Requires the "claude.ai Atlassian" and "claude.ai Microsoft 365" MCP servers.
---

# Teams to Confluence

Transfer information from Microsoft Teams chats into well-structured Confluence pages.

## Workflow

Copy this checklist and track progress:

```
Progress:
- [ ] Step 1: Gather requirements from the user
- [ ] Step 2: Identify the target chat
- [ ] Step 3: Retrieve chat messages
- [ ] Step 4: Synthesize the content
- [ ] Step 5: Propose page details including location and get confirmation
- [ ] Step 6: Create the Confluence page
- [ ] Step 7: Verify and confirm
```

### 1. Gather Requirements from the User

Ask the user for the following (in a single message to avoid back-and-forth):

- **Chat identification**: The name of the Teams chat, or keywords/participants to identify it.
- **What to extract**: What specific information from the chat should go into the Confluence page? Examples: decisions made, action items, technical details, a summary of the full discussion, specific messages about a topic, etc.
- **Date range** (optional): Whether to limit the search to a specific time window.

### 2. Identify the Target Chat

Resolve the chat name to a confirmed chat ID before retrieving messages. Do NOT assume the first chat ID returned is correct.

1. **Use KQL `in:` scoping**: The search tool uses Keyword Query Language (KQL). Use the `in:` scope term to restrict results to a specific chat by name, e.g. `query: 'in:"Claude users" keyword'`. This is the most reliable way to find the correct chat.
2. Extract the `chatId` from the result.
3. Read the chat via its messages URI (`teams:///chats/{chatId}/messages`) using `mcp__claude_ai_Microsoft_365__read_resource` to confirm it's the right chat - check participants and recent content against the user's description.
4. If search results contain messages from multiple chats, cross-reference each chatId with the user's description. Present ambiguous matches to the user and ask them to confirm.
5. Once confirmed, use that `chatId` for all subsequent message retrieval.

### 3. Retrieve Chat Messages

With the confirmed `chatId`, read messages directly from the chat rather than relying solely on keyword search (which may miss messages not indexed by the search API).

- Read messages from `teams:///chats/{chatId}/messages` using `mcp__claude_ai_Microsoft_365__read_resource`.
- Use `mcp__claude_ai_Microsoft_365__chat_message_search` with KQL `in:` scoping (e.g. `'in:"Chat Name" keyword'`) for targeted keyword searches within the chat.
- **Timezone awareness**: Teams stores timestamps in UTC. When the user provides dates, convert them to UTC based on their timezone before applying `afterDateTime`/`beforeDateTime` filters. For example, "13 Feb" in NZDT (UTC+13) starts at Feb 12 ~11:00 UTC.
- **If search returns no results**: Try removing date filters first (the search API may not index all messages). Also try searching for distinctive content phrases rather than generic keywords.
- If the chat has many messages, use pagination (`limit`, `offset`) to retrieve in batches.

### 4. Synthesize the Content

Transform the raw chat messages into a well-structured Confluence page. Do NOT just dump raw messages. Instead:

- Organize by topic or theme, not chronologically (unless a timeline is specifically requested).
- Extract and highlight: key decisions, action items, open questions, technical details.
- Attribute important points to their authors where relevant.
- Remove noise: greetings, off-topic tangents, emoji reactions, duplicate messages.
- Use clear headings, bullet points, and tables where appropriate.
- **Writing style**: Write like a human, not an AI. Use regular dashes (-) instead of em dashes. Keep language natural and concise.

### 5. Propose Page Details

Before creating the page, present the user with:

- **Suggested page title**: Concise, descriptive title based on the extracted content.
- **Suggested location**: Recommend a Confluence space and parent page. Use the Atlassian MCP tools to look up the cloudId, list available spaces, and search for a relevant parent page if the content relates to a specific project or team.
- **Content preview**: Show the user a summary or outline of what the page will contain.

Wait for user confirmation or adjustments before creating.

### 6. Create the Confluence Page

Use `mcp__claude_ai_Atlassian__createConfluencePage` with:

- `cloudId`: From the accessible resources lookup.
- `spaceId`: The chosen space ID.
- `title`: The agreed-upon title.
- `body`: The synthesized content in markdown format.
- `contentFormat`: `"markdown"`.
- `parentId` (optional): If a parent page was selected.

### 7. Verify and Confirm

After creation:

1. Retrieve the newly created page using `mcp__claude_ai_Atlassian__getConfluencePage` to verify it was created correctly.
2. If the page content looks wrong or incomplete, use `mcp__claude_ai_Atlassian__updateConfluencePage` to fix it.
3. Confirm success to the user with the page title, space, and a note that they can share the page URL with their team.

## Edge Cases

- **Large chats**: If the chat has many messages, ask the user to narrow down the date range or topic. Use pagination to retrieve messages in batches.
- **Multiple topics**: If the chat covers several distinct topics, offer to create separate pages or a single page with clearly separated sections.
- **Existing page**: If the user wants to add to an existing Confluence page rather than create a new one, use `mcp__claude_ai_Atlassian__updateConfluencePage` instead. Search for the page first using CQL.
- **Creation failure**: If page creation fails, check the error message, verify the space and parent page IDs, and retry. Report the specific error to the user if it cannot be resolved.
