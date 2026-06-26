---
name: repro-on-desktop-windows-app
description: Reproduce and verify a UI layout bug in a WPF or WinForms desktop application — a thin entry point to /repro-visual's WPF path. Attaches via wpfbuddy-mcp (UIAutomation), snapshots the automation tree, drives interactions via invoke/set_value/grid tools, captures via PrintWindow, and re-verifies on the installed build. No browser, no Node, no Playwright. Triggers: WPF UI bug, WinForms layout wrong, measure the WPF window, desktop app layout off, repro on the Windows app, element is too small in the desktop app, DPI scaling issue, wpfbuddy.
---

This is the **WPF / WinForms** entry point to the `/repro-visual` skill. Follow `repro-visual`'s **WPF / native-Windows path** — Step 0 detection is already resolved (it's a Windows desktop app).

**No init step needed.** The WPF workflow uses wpfbuddy-mcp — nothing to scaffold or check in. Skip `/repro-visual-init` entirely.

Key reminders:

- **Load wpfbuddy tools first** — they may be deferred MCP tools. Run ToolSearch for `wpf_list_apps` before calling any `wpf_*` tool. If no tools are found, wpfbuddy-mcp is not registered; follow the one-time setup in `repro-visual`'s `references/wpf-desktop.md`.
- **Attach to the running app** via `wpf_list_apps` → `wpf_attach` → `wpf_list_windows` → `wpf_select_window`. If a human is mid-task, attach and leave the app running.
- **Re-select the window** after any navigation — dialogs and new windows change the active window context.
- **Screenshot via PrintWindow** (PS 5.1 `powershell.exe`, flag `2`). Never `wpf_screenshot` (screen grab — occlusion + privacy hazard + context overflow) or `CopyFromScreen`.
- **DPI, not viewport width** — re-check at 100% / 125% / 150% display scaling.
- **Grid rows need double-click** to activate, not just select. `wpf_grid_find_row` matches on Name, not cell text — act by index when in doubt.

Full tool reference, PrintWindow recipe, and gotchas are in `repro-visual`'s **`references/wpf-desktop.md`**.
