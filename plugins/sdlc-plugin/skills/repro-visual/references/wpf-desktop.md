# WPF / WinForms desktop repro — wpfbuddy-mcp reference

Primary backend for `/repro-visual`'s WPF / WinForms path. wpfbuddy-mcp is a UIAutomation-based MCP server that attaches to any running WPF app and provides inspect, measure, interact, assert, and generate tools without requiring changes to the target app.

---

## Setup — register wpfbuddy-mcp once

If `wpf_list_apps` is not available in the session, build and register wpfbuddy:

```powershell
# Run from a directory where you want to clone the repo
git clone https://github.com/lysiuchenko/wpf-buddy-mcp
cd wpf-buddy-mcp

$projectPath = 'src/WpfBuddy.Mcp.Server/WpfBuddy.Mcp.Server.csproj'
$dllPath     = 'src/WpfBuddy.Mcp.Server/bin/Release/net8.0-windows/WpfBuddy.Mcp.Server.dll'
$serverName  = 'wpfbuddy-mcp'

dotnet build -c Release $projectPath

if (-not (Test-Path $dllPath)) { throw "DLL not found: $dllPath" }

try { claude mcp remove $serverName --scope user 2>$null } catch {}
claude mcp add $serverName --scope user -- dotnet $dllPath
```

After registering, restart the Claude Code session so the tools load.

---

## Deferred tools — load schemas before use

wpfbuddy tools may be registered as deferred MCP tools. Before calling any `wpf_*` tool in a fresh agent context, run ToolSearch to load their schemas:

```
ToolSearch("select:wpf_list_apps,wpf_attach,wpf_list_windows,wpf_select_window,wpf_focus_window,wpf_snapshot,wpf_explain_screen,wpf_accessibility_snapshot,wpf_click,wpf_double_click,wpf_invoke,wpf_set_value,wpf_select_by_text,wpf_send_keys,wpf_wait_for_window,wpf_wait_for_navigation,wpf_wait_for_element,wpf_wait_for_text,wpf_grid_get_rows,wpf_grid_find_row,wpf_grid_select_row,wpf_grid_double_click_row,wpf_grid_get_cell,wpf_assert_text,wpf_assert_value,wpf_assert_exists,wpf_assert_visible,wpf_assert_enabled,wpf_assert_grid_cell,wpf_generate_smoke_tests,wpf_generate_regression_tests,wpf_generate_accessibility_tests,wpf_generate_page_objects")
```

---

## Connect workflow

```
wpf_list_apps()              // lists running Windows processes + PIDs; find the target
wpf_attach(pid=...)          // attach by PID (or processName='MyApp')
wpf_list_windows()           // list windows in the attached process
wpf_select_window(...)       // select the target window; re-call after navigations
wpf_focus_window()           // bring window to foreground (useful before PrintWindow)
```

**Multiple instances:** attach by PID, not process name, when more than one instance is running. Verify the window title / AutomationId after attaching.

**After navigation:** when a dialog or new window opens, call `wpf_select_window` again — the active window context changes.

**Attach vs. launch:** prefer attaching to an already-running instance. If a human is mid-task, never kill or restart the app. For throwaway test runs, launch via `Start-Process`, then call `wpf_wait_for_window` before attaching.

---

## Inspect and measure

### `wpf_snapshot`

Returns a structured JSON tree: element bounds, patterns, **`className`** (the real WPF control type — `DataGrid`, `ComboBox`, `TabItem`, etc.), `isOffscreen`, AutomationId. Auto-diagnoses missing and duplicate AutomationIds. Use this as the primary measurement tool. Read bounds to check sizing / position; check `isOffscreen` for elements that should be visible but are scrolled off or behind another control.

> Prefer `className` over UIAutomation `ControlType` — it exposes the actual WPF class name, which `ControlType` collapses into coarse categories.

### `wpf_explain_screen`

AI-friendly summary: screen purpose, visible inputs + current values, available actions, flagged issues (disabled fields, empty required fields). Start here when you don't yet know what screen you're on.

### `wpf_accessibility_snapshot`

Accessibility-tree view. Use for label coverage, ARIA-equivalent roles, or screen-reader-relevant diagnosis.

---

## Grid / list tools

Many WPF UIs are dominated by DataGrids. Use these directly instead of walking the snapshot tree:

```
wpf_grid_get_rows()                         // all rows as structured data
wpf_grid_find_row(searchText=...)           // find row by text (see gotcha below)
wpf_grid_get_cell(row=..., col=...)         // get a specific cell value
wpf_grid_select_row(row=...)                // select (highlight) a row
wpf_grid_double_click_row(row=...)          // double-click to activate (open detail / invoke action)
```

---

## Interact

```
wpf_click(automationId=...)                  // single click
wpf_double_click(automationId=...)           // double-click (needed for many row activations)
wpf_invoke(automationId=...)                 // invoke the Invoke pattern (buttons, menu items)
wpf_set_value(automationId=..., value=...)   // set TextBox or ComboBox value
wpf_select_by_text(automationId=..., text=...) // select ComboBox / ListBox item by text
wpf_send_keys(keys=...)                      // send keyboard input to focused element
```

---

## Synchronize — use these instead of fixed sleeps

Desktop apps start slowly and variably. Always poll; never use `Start-Sleep` with a fixed duration.

```
wpf_wait_for_window(title=..., timeout=60)       // wait for window with matching title
wpf_wait_for_navigation(timeout=30)             // wait for window content to change
wpf_wait_for_element(automationId=..., timeout=10) // wait for element to appear
wpf_wait_for_text(text=..., timeout=10)          // wait for specific text on screen
```

---

## Assert and generate

After proving a fix, lock in assertions so regressions are detectable:

```
wpf_assert_text(automationId=..., expected=...)      // assert visible text
wpf_assert_value(automationId=..., expected=...)     // assert field value
wpf_assert_exists(automationId=...)                 // assert element present
wpf_assert_visible(automationId=...)                // assert not isOffscreen
wpf_assert_enabled(automationId=...)                // assert not disabled
wpf_assert_grid_cell(row=..., col=..., expected=...) // assert grid cell value
```

Generate test scaffolding from the current screen state:

```
wpf_generate_smoke_tests()            // smoke test suite for the current screen
wpf_generate_regression_tests()       // regression tests based on current state
wpf_generate_accessibility_tests()    // accessibility checks
wpf_generate_page_objects()           // page object model for the current screen
```

---

## Screenshots — PrintWindow, NOT `wpf_screenshot`

**Do not use `wpf_screenshot` or `wpf_screenshot_element`.** They grab the physical screen region at the window's coordinates: any overlapping window bleeds through (occlusion + privacy hazard — can capture unrelated apps or sensitive data), and the inline base64 return value runs to hundreds of KB, overflowing agent context on every call.

Instead, use Win32 **`PrintWindow(hwnd, hdc, 2 /*PW_RENDERFULLCONTENT*/)`**. It renders from the window's own surface buffer and works even when the window is fully occluded, off-screen, minimised, or on a far monitor. Save directly to a PNG file; the agent opens it natively.

Run this in **PowerShell 5.1 (`powershell.exe`)** — not `pwsh` 7. `System.Drawing.Bitmap` requires .NET Framework, which is built into PS 5.1 but not available in PS 7 without extra NuGet packages.

```powershell
# powershell.exe (PS 5.1 ONLY)
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdc, uint nFlags);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out RECT r);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }
}
"@

function Capture-Window($hwnd, $outPath) {
    $r = New-Object Win32+RECT
    [Win32]::GetWindowRect($hwnd, [ref]$r) | Out-Null
    $w = $r.R - $r.L; $h = $r.B - $r.T
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    [Win32]::PrintWindow($hwnd, $hdc, 2) | Out-Null   # 2 = PW_RENDERFULLCONTENT
    $g.ReleaseHdc($hdc); $g.Dispose()
    $bmp.Save($outPath); $bmp.Dispose()
}
```

Get `$hwnd` from `wpf_list_windows` output, or enumerate via `EnumWindows` (see `wpf-uiautomation.md`). Save to a temp path and read the PNG natively.

> If a future version of wpfbuddy offers off-screen / PrintWindow-based capture (verify it is NOT a screen grab), prefer that and drop this recipe.

---

## Optional: in-process probe

If wpfbuddy can inject a probe into the running app, additional tools become available:

```
wpf_probe_connect()                    // attempt in-process probe injection
wpf_get_viewmodel(automationId=...)    // get the bound ViewModel object
wpf_get_bindings(automationId=...)     // list data bindings on an element
wpf_get_binding_errors()              // list binding errors from the BindingError stream
```

Without a probe, all UIAutomation-based tools still work. Probe mode surfaces ViewModel state and binding errors that UIAutomation can't see. Try it when diagnosis stalls on a data question.

---

## Gotchas

**Rows need double-click, not invoke.** WPF DataGrid rows expose `SelectionItem` (highlight) but often NOT `Invoke` (activate). Many detail dialogs have no OK button — they open on double-click. `wpf_grid_select_row` highlights; `wpf_grid_double_click_row` activates.

**`wpf_grid_find_row(searchText=...)` matches on Name, not cell text.** The row's `Name` is often the bound object's type name, identical for every row — so it returns 0 matches for a value you can plainly see. Get the row index from `wpf_grid_get_rows` and act by index instead.

**Multiple app instances.** Attach by PID when more than one instance is running. Verify the window title / AutomationId after attaching.

**Navigation changes the active window.** After opening a dialog or navigating to a new screen, call `wpf_select_window` again before inspecting or interacting.

**The viewport-width axis doesn't exist.** The real axes are DPI scaling (100% / 125% / 150%) and window state (normal / maximised / resized). Re-check layout at each DPI scale just as the web path checks each viewport width.

**44px touch-target rule doesn't apply on desktop.** Toolbar buttons and menu items are legitimately 16–26px. Do not flag these on the desktop path.

**Never kill a user's live session.** "Attach and leave running" is the normal mode when a human is using the app. Only `Stop-Process` a throwaway instance you launched yourself.

**ASCII only in PS 5.1 scripts.** A non-ASCII character (em-dash, smart quote, etc.) saved in a UTF-8-without-BOM `.ps1` file silently breaks the PS 5.1 parser. Write fallback PowerShell scripts in plain ASCII.

**`BoundingRectangle.Empty` guard (raw UIAutomation fallback only).** If you ever bypass wpfbuddy and use raw UIAutomation: `BoundingRectangle` can be `Rect.Empty` (±Infinity) for virtualised, collapsed, or off-screen elements. Guard before any arithmetic or int cast — it throws. `Rect.Empty` is distinct from `IsOffscreen=true`.

---

## Web → WPF mapping

| repro-visual (web) | WPF equivalent |
|---|---|
| Playwright + headless Chromium | wpfbuddy-mcp (UIAutomation); optional in-proc probe |
| Navigate to a route (`--path`) | Launch / attach; `wpf_wait_for_window` / `wpf_wait_for_navigation` |
| CSS selector | AutomationId (= XAML `x:Name`) / Name / className |
| `getBoundingClientRect()` | Element bounds from `wpf_snapshot` |
| `page.click` / `page.fill` | `wpf_click` / `wpf_invoke` / `wpf_set_value`; grid tools |
| DOM injection to prove fix | Interact via wpfbuddy pattern calls; or rebuild + re-measure |
| `--screenshot` | PrintWindow → PNG file (NOT `wpf_screenshot` / screen-scrape) |
| `--device 360` / viewport width | DPI scaling (100% / 125% / 150%) + window state |
| Prod base URL | Built / installed `.exe` / ClickOnce / MSIX |
| Cached login (storageState) | Live attached session (find PID; don't re-auth; don't kill) |
| `--seed` via app API | Out of scope for UI-repro (data comes from DB / service layer) |
| 44px mobile touch-target rule | N/A on desktop |

---

## Fallback — when wpfbuddy is unavailable

If wpfbuddy-mcp cannot be registered (non-Windows environment, network restriction, etc.), fall back to raw PowerShell 5.1 + UIAutomation. See `wpf-uiautomation.md` for the complete recipe. No extra dependencies — works on any Windows machine with .NET Framework — but considerably more boilerplate and no interact / assert / generate tools.
