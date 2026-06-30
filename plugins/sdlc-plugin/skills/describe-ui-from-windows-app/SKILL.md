---
name: describe-ui-from-windows-app
description: 'Inspect a running Windows desktop application (WPF, WinForms, Win32) via the Windows UI Automation framework and produce a structured UI description under docs/as-built/ui-description/: window inventory, per-window control tree dumps, screenshots, and field observations. Uses pywinauto print_control_identifiers() or FlaUI tree walk — no source code required, works against any running process. WPF and WinForms expose rich UIA trees; old Win32/MFC apps with custom-drawn controls may need an OCR fallback. Must run on Windows. Useful standalone for accessibility audits, UI documentation, or test planning — and is the Windows capture input for /requirements-from-app. Triggers: describe this Windows app, capture WPF UI, document WinForms app, inventory desktop app, inspect running Windows app.'
---

Inspect a running Windows desktop application through the Windows UI Automation (UIA) framework. No source code, debug build, or instrumentation required — only a running process. Output is raw observation; BA synthesis happens in `/requirements-from-app`.

## Prerequisites

- **Must run on Windows** — UIA is a Windows-only framework; this skill self-aborts on macOS/Linux
- **pywinauto** (Python, preferred): `pip install pywinauto` — works for WPF, WinForms, Win32
- **FlaUI** (alternative, .NET): install `FlaUInspect` for interactive pre-validation; use `FlaUI.Core` NuGet package for scripted access
- **Inspect.exe** (optional, interactive pre-validation): ships with Windows SDK; available in Visual Studio tools or via `winget install Microsoft.WindowsSDK`
- The target app is already running

---

## Phase 0 — Preflight

1. Confirm the environment is Windows: run `[System.Environment]::OSVersion.Platform` (PowerShell). If the result is not `Win32NT`, stop immediately and print:
   > This skill requires Windows. pywinauto and the Windows UI Automation framework are Windows-only. Run this skill from a Windows machine or VM.

2. Check pywinauto: `python -c "import pywinauto; print('ok')"`. If it fails:
   > Install pywinauto: `pip install pywinauto`

3. Ask the user:
   - **Process name or window title** of the running app (e.g. `notepad.exe`, or "Invoice Manager")
   - **App framework** if known (WPF / WinForms / Win32 / unknown) — determines which UIA backend to prefer
   - **Scope** — are there any dialogs, settings pages, or sections to include or exclude?

4. Locate the running process and confirm the app is found:
   ```python
   from pywinauto import Desktop
   windows = Desktop(backend="uia").windows()
   # List window titles so user can confirm
   ```
   If the process is not found, ask the user to launch it and try again.

---

## Phase 1 — Window and dialog discovery

Use pywinauto to enumerate all top-level windows and child dialogs belonging to the target app:

```python
from pywinauto import Application

# Connect to running app (try "uia" backend first for WPF/WinForms; fall back to "win32" for old MFC)
app = Application(backend="uia").connect(title_re="<window title pattern>")

# List top-level windows
for win in app.windows():
    print(win.window_text(), win.class_name(), win.rectangle())
```

Build a working window list: `[window name, class name, status: pending/captured/skipped]`

Navigate the app manually (or by scripting menu clicks) to surface modal dialogs, settings panels, and secondary windows. Each distinct UI surface that appears should be added to the list.

If the app has a menu bar, enumerate all top-level menu items and note which ones open new windows or dialogs.

---

## Phase 2 — Deep capture per window

For each window/dialog in the list (status: pending):

1. **Bring to foreground**: `win.set_focus()`
2. **Screenshot**: use `pywinauto`'s `win.capture_as_image()` or PowerShell's `Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen` + `[System.Drawing.Bitmap]::new(...)` to capture the window region. Save to `docs/as-built/ui-description/screenshots/<window-name>.png`.
3. **Control tree dump**:
   ```python
   win.print_control_identifiers(filename="<window-name>-tree.txt")
   ```
   This dumps the full UIA control hierarchy with: control type, automation ID, name, class, value, enabled/visible state.
4. **Field observations**: from the control tree, note:
   - Edit controls: label (nearest static text), automation ID, value constraints if readable
   - Buttons: name, enabled state
   - ComboBoxes and ListBoxes: label, items if enumerable
   - DataGrids / ListViews: column headers
   - Tab controls: tab page names (each tab page may need separate capture)
   - CheckBoxes and RadioButtons: label, group, default state
5. Mark window status: captured

**OCR fallback** — if the control tree is sparse (old Win32 / MFC / custom-drawn controls):
- Note which controls returned no name or automation ID
- Use a screenshot + OCR to extract visible text labels as a best-effort fallback
- Annotate these fields as "OCR-derived — verify manually"

**Tab pages and accordions**: if a window has tabs or expandable sections, capture each tab/section separately as a sub-surface. Name them `<window-name>__<tab-name>.md`.

---

## Phase 3 — Write output

Create `docs/as-built/ui-description/` with this structure:

```
docs/as-built/ui-description/
  screen-inventory.md
  screenshots/
    <window-name>.png
  screens/
    <window-name>.md
    <window-name>__<tab-name>.md   (for tabbed windows)
```

**`screen-inventory.md`:**
```markdown
# Window Inventory — <App Name>

| Window / Dialog | Class | Framework hint | Screenshot | Notes |
|-----------------|-------|----------------|------------|-------|

## Surfaces not captured
- <dialogs not triggered, out-of-scope sections>
```

**`screens/<window-name>.md`:**
````markdown
# <Window Name>

**Window class:** <class name>
**Screenshot:** ![<window name>](../screenshots/<window-name>.png)

## Controls
| Control type | Label / Name | Automation ID | Value / Options | Required | Notes |
|--------------|--------------|---------------|-----------------|----------|-------|

## Navigation
(Buttons that open other windows/dialogs; menu items leading elsewhere)

## Control tree
```
<paste print_control_identifiers() output here>
```
````

---

## Commit (standalone use)

If this skill was invoked directly rather than through `/requirements-from-app`, commit the output following [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). Use commit message: `docs(as-built): capture Windows UI description — <app name>`

If invoked by `/requirements-from-app`, skip this step — that skill owns the commit.

---

## Guardrails

- Use `backend="uia"` for WPF and WinForms; switch to `backend="win32"` only if UIA returns an empty tree
- Do not attempt to capture windows belonging to a different process (UIA cannot cross the `Run As` boundary — document this as a constraint, not a bug)
- Do not interpret business rules — record field names and automation IDs literally
- If `print_control_identifiers()` raises `MatchError` or returns a tree with fewer than 5 controls for a visually rich window, note it as "sparse UIA tree — OCR fallback applied"
- Never close or dismiss dialogs automatically — always ask the user before interacting with the app beyond focus + screenshot
