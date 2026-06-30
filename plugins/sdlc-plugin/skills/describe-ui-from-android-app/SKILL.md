---
name: describe-ui-from-android-app
description: 'Inspect a running Android app (on an emulator or real device via ADB) and produce a structured UI description under docs/as-built/ui-description/: screen inventory, per-screen UIAutomator XML hierarchy dumps, screenshots, and field observations. Uses adb shell uiautomator dump for zero-setup hierarchy extraction plus python-uiautomator2 or Appium UIAutomator2 for navigation scripting. No app source code required. Production apps with anti-tampering or root detection may block UIAutomator — documented as a gap. Useful standalone for accessibility audits, UI documentation, or test planning — and is the Android capture input for /requirements-from-app. Triggers: describe this Android app, capture Android UI, document Android app screens, inventory Android app, inspect APK.'
---

Inspect a running Android application via the Android UIAutomator accessibility framework. No source code, debug build, or APK modification required. Output is raw observation; BA synthesis happens in `/requirements-from-app`.

## Prerequisites

- **ADB** (Android Debug Bridge): `adb version` — ships with Android Studio or install via `brew install android-platform-tools` (macOS) / `apt install adb` (Linux) / Android Studio SDK Manager (Windows)
- **Android emulator or real device**:
  - Emulator: Android Studio AVD Manager, or `emulator -avd <name>`
  - Real device: enable Developer Options → USB Debugging; connect via USB
- **python-uiautomator2** (optional, for scripted navigation): `pip install uiautomator2`
- **Appium + UIAutomator2 driver** (alternative for richer navigation): `npm install -g appium && appium driver install uiautomator2`
- The target app is installed and the screen you want to start from is visible

---

## Phase 0 — Preflight

1. Check ADB and device: `adb devices` — confirm one device is listed as `device` (not `offline` or `unauthorized`). If empty, prompt the user to connect a device or start an emulator.

2. Check screen state: `adb shell dumpsys window windows | grep mCurrentFocus` — confirm the target app is in the foreground.

3. Ask the user:
   - **App package name** (e.g. `com.example.myapp`) — find it via `adb shell pm list packages | grep <keyword>`
   - **Starting screen** — describe where to begin (e.g. "the login screen", "the main dashboard")
   - **Flows to cover** — which user journeys should be navigated? (e.g. "onboarding, item creation, settings")
   - **Scope** — any sections to skip?

4. Warn upfront: production apps with anti-tampering, root detection, or accessibility blocking (common in banking and payments apps) may return empty hierarchy dumps. This is noted as a gap, not a failure.

---

## Phase 1 — Screen discovery

Navigate through the app's major flows. For each screen that appears:

**Quick hierarchy check (always first):**
```bash
adb shell uiautomator dump /sdcard/ui_dump.xml
adb pull /sdcard/ui_dump.xml docs/as-built/ui-description/hierarchies/<screen-name>.xml
```

If the XML contains meaningful content (more than 3 nodes), the screen is capturable. If the XML is nearly empty (`<hierarchy rotation="0"><node ... /></hierarchy>` with no children), note as "sparse — anti-tampering suspected."

**Navigation approaches** (use whichever fits the app):
1. Ask the user to navigate to each screen manually and trigger a dump when ready
2. Use python-uiautomator2 to tap elements by resource-id or text:
   ```python
   import uiautomator2 as u2
   d = u2.connect()
   d(resourceId="com.example.myapp:id/button_next").click()
   ```
3. Use Appium UIAutomator2 driver for more complex navigation sequences

Build a working screen list: `[screen name, app state/flow step, status: pending/captured/sparse]`

---

## Phase 2 — Deep capture per screen

For each screen in the list (status: pending):

1. Navigate to the screen
2. **Screenshot**:
   ```bash
   adb shell screencap -p /sdcard/screenshot.png
   adb pull /sdcard/screenshot.png docs/as-built/ui-description/screenshots/<screen-name>.png
   ```
3. **UIAutomator hierarchy dump**:
   ```bash
   adb shell uiautomator dump /sdcard/ui_dump.xml
   adb pull /sdcard/ui_dump.xml docs/as-built/ui-description/hierarchies/<screen-name>.xml
   ```
4. **Field observations** from the XML hierarchy:
   - `<node class="android.widget.EditText">`: input field — note `text`, `hint`, `content-desc`, `resource-id`
   - `<node class="android.widget.Button">`: button — note `text`, `content-desc`
   - `<node class="android.widget.TextView">`: label or display text
   - `<node class="android.widget.Spinner">`: dropdown — note available options if enumerable
   - `<node class="android.widget.CheckBox">` / `RadioButton`: note label and checked state
   - `<node class="android.widget.RecyclerView">` / `ListView`: list structure — capture one representative item
5. Mark screen status: captured (or sparse if hierarchy was empty)

---

## Phase 3 — Write output

```
docs/as-built/ui-description/
  screen-inventory.md
  screenshots/
    <screen-name>.png
  hierarchies/
    <screen-name>.xml
  screens/
    <screen-name>.md
```

**`screen-inventory.md`:**
```markdown
# Screen Inventory — <App Name> (Android)

| Screen | Flow / entry point | Capture status | Screenshot |
|--------|--------------------|----------------|------------|

## Sparse / not captured
- <screens where UIAutomator returned empty hierarchy>
```

**`screens/<screen-name>.md`:**
```markdown
# <Screen Name>

**Flow position:** <e.g. "Onboarding — step 2 of 4">
**Screenshot:** ![<screen name>](../screenshots/<screen-name>.png)
**Hierarchy file:** [XML](../hierarchies/<screen-name>.xml)

## Fields
| Label / hint | resource-id | Type | Notes |
|--------------|-------------|------|-------|

## Interactive elements
| Element | resource-id | Action |
|---------|-------------|--------|

## Content structure
(Lists, cards, RecyclerViews — describe the item template)
```

---

## Commit (standalone use)

If this skill was invoked directly rather than through `/requirements-from-app`, commit the output following [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). Use commit message: `docs(as-built): capture Android UI description — <app name>`

If invoked by `/requirements-from-app`, skip this step — that skill owns the commit.

---

## Guardrails

- Do not attempt to bypass anti-tampering protections — document the affected screens as gaps
- Do not install or modify the APK to enable inspection
- If a screen is inside a WebView (`android.webkit.WebView`), note it as "WebView content — use `/describe-ui-from-web-app` for this section"
- Capture one representative item from lists and RecyclerViews — do not scroll endlessly
- Do not interpret business rules — record field names and resource-IDs literally
