# WPF / WinForms UI measurement — recipe and gotchas

Recipe for reproducing and measuring layout bugs in a running WPF or WinForms desktop app
without source-code access, using only PowerShell and Windows' built-in UIAutomation API.

---

## Runtime requirement: Windows PowerShell 5.1 (`powershell.exe`)

Run everything in **PowerShell 5.1** (`powershell.exe`), **not** PowerShell 7 (`pwsh`).

On `pwsh` 7, `Add-Type` for `System.Drawing.Bitmap` fails — the type is forwarded to
`System.Drawing.Common` (a Windows-only NuGet package that isn't present unless you add it).
`System.Collections.Generic.List<>` can also fail to resolve. PS 5.1 uses .NET Framework 4.x
where `System.Drawing`, `System.Windows.Automation.*`, and UIAutomation types are built in —
the same runtime as the WPF app itself.

---

## Screenshot: always use PrintWindow, never CopyFromScreen

`Graphics.CopyFromScreen` grabs the **physical screen region** at the window's coordinates.
If the window is not truly in the foreground — occluded by another window, off-screen, or
minimised — you capture whatever is physically behind it: another app's window, the user's
calendar, a private chat, or a blank desktop. This is a **privacy hazard** that can leak
sensitive content without any warning.

`PrintWindow(hwnd, hdc, PW_RENDERFULLCONTENT=2)` renders **from the window's own surface
buffer**. It works even when the window is fully occluded, off-screen, or minimised, and
never captures other applications.

```powershell
# powershell.exe (PS 5.1)
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

---

## Finding the window handle

WPF windows use the Win32 class `HwndWrapper[...]`. Enumerate by PID, visible, and
class prefix — **do not** rely on the window title (WPF apps often set it at runtime):

```powershell
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Text;
public class WinEnum {
    public delegate bool EnumProc(IntPtr hwnd, IntPtr lp);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr lp);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, StringBuilder sb, int max);
    public static List<IntPtr> Find(int targetPid) {
        var found = new List<IntPtr>();
        EnumWindows((h, _) => {
            uint pid; GetWindowThreadProcessId(h, out pid);
            if (pid != targetPid || !IsWindowVisible(h)) return true;
            var sb = new StringBuilder(256);
            GetClassName(h, sb, 256);
            if (sb.ToString().StartsWith("HwndWrapper")) found.Add(h);
            return true;
        }, IntPtr.Zero);
        return found;
    }
}
"@

# Launch the app, poll until the real window appears
$proc   = Start-Process ".\bin\Debug\MyApp.exe" -PassThru
$hwnd   = $null
$cutoff = (Get-Date).AddSeconds(60)   # generous: desktop apps start slowly
while (-not $hwnd -and (Get-Date) -lt $cutoff) {
    Start-Sleep -Milliseconds 500
    $handles = [WinEnum]::Find($proc.Id)
    # Skip the splash: wait until a second window appears, or title is set, etc.
    if ($handles.Count -ge 1) { $hwnd = $handles[0] }
}
if (-not $hwnd) { throw "Window did not appear within 60s" }
```

**Splash screen:** WPF apps often show a `SplashScreen` first. A WPF splash opens its own
`HwndWrapper` window. Wait until you see the real `<Window>` — typically identifiable by a
non-null `AutomationId` or a specific title set at runtime. Polling is safer than a fixed sleep.

---

## Measuring via UIAutomation

```powershell
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)

# Walk all descendants
$cond  = [System.Windows.Automation.Condition]::TrueCondition   # NOT AutomationElement.TrueCondition
$scope = [System.Windows.Automation.TreeScope]::Descendants
$all   = $root.FindAll($scope, $cond)

foreach ($el in $all) {
    $r    = $el.Current.BoundingRectangle
    $type = $el.Current.ControlType.ProgrammaticName -replace 'ControlType\.', ''
    $name = $el.Current.Name
    $id   = $el.Current.AutomationId
    if ($r.Width -gt 0) {
        Write-Host ("{0,-12} id={1,-20} name='{2}' bounds={3},{4},{5},{6}" -f `
            $type, $id, $name, [int]$r.Left, [int]$r.Top, [int]$r.Width, [int]$r.Height)
    }
}
```

**Key notes:**
- `AutomationId` in UIAutomation = `x:Name` in XAML (WPF maps these automatically at load time).
  Use it to find specific controls reliably.
- `BoundingRectangle` is in **screen pixels at the current DPI scale**. At 100% (96 DPI),
  `BoundingRectangle.Width` matches XAML `Width` exactly for fixed-size elements.
- At 125%/150% scaling, pixel values are scaled up. Check your display's DPI when interpreting
  measurements.
- `[System.Windows.Automation.Condition]::TrueCondition` — note the `[Condition]::` prefix.
  `AutomationElement.TrueCondition` does NOT exist and throws `ArgumentNullException`.

---

## WPF vs web: key axis differences

| Web (`repro-visual`)       | WPF equivalent                                      |
|----------------------------|-----------------------------------------------------|
| Viewport width (`--device 360`) | DPI / display scaling (100% / 125% / 150%)    |
| CSS `getBoundingClientRect()` | `AutomationElement.Current.BoundingRectangle`    |
| CSS selector               | `AutomationId` (= XAML `x:Name`) or `Name`          |
| Prod URL                   | Path to built / installed `.exe`                    |
| Cached session (`storageState`) | (no clean analogue — app logs in per launch)  |
| Headless browser           | Launch the real `.exe`                              |

---

## Prove the fix (WPF equivalent of DOM injection)

True DOM-style injection (patch a live process's UI without a deploy) is not practical on
WPF without attaching a debugger or a tool like Snoop. The practical equivalent:

1. Make the XAML/C# change.
2. `dotnet build --project <csproj>` (rebuild only the affected project — keep it fast).
3. Re-launch, re-capture, re-measure with the same scripts.
4. If numbers are now correct → the fix is right. Commit it.

---

## Richer alternatives

- **FlaUI** (NuGet: `FlaUI.Core` + `FlaUI.UIA3`) — a .NET library wrapping UIAutomation 3.
  More ergonomic API than raw COM interop. Good for scripted navigation (click buttons, fill
  fields) before measuring.
- **WinAppDriver** — Appium-compatible REST driver for Windows apps. Lets you drive the app
  with Appium test scripts.
- **Snoop** — GUI tool for inspecting live WPF visual trees (not scriptable, but useful for
  one-off investigation).

For simple measurement (bounds + tree dump), the raw PowerShell recipe above requires no
extra dependencies and works on any Windows machine.
