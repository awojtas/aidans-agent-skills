---
name: repro-on-desktop-windows-app
description: Reproduce and verify a UI layout bug in a WPF or WinForms desktop application — a thin entry point to /repro-visual's native-Windows path. Launches the exe, captures via PrintWindow, measures element bounds via UIAutomation BoundingRectangle, diagnoses from the automation tree, and re-verifies on the installed build. No browser, no Node, no Playwright — pure PowerShell 5.1 + Win32. Triggers: WPF UI bug, WinForms layout wrong, measure the WPF window, desktop app layout off, repro on the Windows app, element is too small in the desktop app, DPI scaling issue.
---

This is the **WPF / WinForms** entry point to the `/repro-visual` skill. Follow `repro-visual`'s **WPF / native-Windows path** — Step 0 detection is already resolved (it's a Windows desktop app).

Key reminders for this path:

- Run all PowerShell in **`powershell.exe` (PS 5.1)**, not `pwsh` — `.NET Framework` types (`System.Drawing`, `UIAutomation*`) are unavailable in PS 7.
- Screenshot via **`PrintWindow`** with flag `2` (`PW_RENDERFULLCONTENT`). Never `CopyFromScreen`.
- Measure via `AutomationElement.FromHandle($hwnd)` + `FindAll(Descendants, [Condition]::TrueCondition)`. `BoundingRectangle` gives screen-pixel bounds at the current DPI.
- Re-check at **100% / 125% / 150% DPI** — that's the WPF equivalent of checking multiple viewport widths.
- Poll for the window (60s+ timeout, 500ms intervals) — desktop apps start slowly and variably.

Full scripts, gotchas, and alternatives are in `repro-visual`'s **`references/wpf-uiautomation.md`**.
