---
name: describe-ui-from-ios-app
description: 'Inspect a running iOS app (Xcode simulator or real device) via Appium XCUITest and produce a structured UI description under docs/as-built/ui-description/: screen inventory, per-screen view hierarchy XML, screenshots, and field observations. Hard requirement: macOS with Xcode installed — skill self-aborts with install instructions on non-macOS platforms. Simulator works without Apple Developer cert; real device requires signing. Uses Appium XCUITest driver and getPageSource() for hierarchy extraction. Useful standalone for accessibility audits, UI documentation, or test planning — and is the iOS capture input for /requirements-from-app. Triggers: describe this iOS app, capture iOS UI, document iOS app screens, inventory iOS app, inspect iPhone app.'
---

Inspect a running iOS application via the Appium XCUITest driver. Output is raw observation; BA synthesis happens in `/requirements-from-app`.

## Prerequisites

**This skill requires macOS. It will not work on Windows or Linux.**

Check the environment first (Phase 0, step 1) and self-abort if not on macOS.

Required tooling:
- **macOS** with **Xcode** installed (`xcode-select --install`)
- **Appium** (server): `npm install -g appium`
- **XCUITest driver**: `appium driver install xcuitest`
- **Python Appium client**: `pip install Appium-Python-Client`
- **Appium Inspector** (optional, for interactive pre-validation): download from [github.com/appium/appium-inspector](https://github.com/appium/appium-inspector)

For **simulator** (no signing needed):
- Xcode simulator with the target iOS version installed: `xcrun simctl list devices`
- App installed in the simulator (`.app` bundle, no signing required)

For **real device** (requires signing):
- Valid Apple Developer account
- Device registered in the Apple Developer portal
- Provisioning profile + signing certificate configured in Xcode

---

## Phase 0 — Preflight

1. **Check platform**: run `uname` via Bash. If the result is not `Darwin`, stop immediately and print:
   > This skill requires macOS. The XCUITest framework is Apple-only and cannot run on Windows or Linux. To use this skill, run it from a macOS machine with Xcode installed. For an alternative, `/describe-ui-from-android-app` does not have this restriction.

2. Check Appium: `appium --version`. If not found: `npm install -g appium`

3. Check XCUITest driver: `appium driver list --installed`. If `xcuitest` not listed: `appium driver install xcuitest`

4. Ask the user:
   - **Simulator or real device?**
   - **Bundle ID** of the target app (e.g. `com.example.myapp`) — find it in Xcode project settings, or `xcrun simctl get_app_container booted <bundle-id>` for simulator
   - **iOS simulator name** (e.g. `iPhone 16`) or device UDID for real device
   - **Starting screen** — where to begin the walkthrough
   - **Flows to cover** — which user journeys to navigate
   - **Scope** — any sections to skip?

5. Start Appium server in the background: `appium --port 4723 &`

6. Start the app on the simulator/device and confirm it launches:
   ```python
   from appium import webdriver
   caps = {
     "platformName": "iOS",
     "appium:deviceName": "<simulator name or UDID>",
     "appium:bundleId": "<bundle id>",
     "appium:automationName": "XCUITest",
   }
   driver = webdriver.Remote("http://localhost:4723", caps)
   ```

---

## Phase 1 — Screen discovery

Navigate through the app's major flows. For each screen:

1. Get the current view hierarchy: `driver.page_source` → XML string
2. If the XML contains meaningful content (more than 5 elements), the screen is capturable
3. Add to working screen list: `[screen name, flow step, status: pending/captured]`

Navigate between screens by:
- `driver.find_element(By.ACCESSIBILITY_ID, "<element name>").click()` — preferred (uses accessibility labels)
- `driver.find_element(By.XPATH, "//XCUIElementTypeButton[@name='...']").click()` — fallback

For each screen that requires a specific user action to appear (modal, alert, sheet), note the trigger and navigate there manually.

---

## Phase 2 — Deep capture per screen

For each screen in the list (status: pending):

1. Navigate to the screen
2. **Screenshot**:
   ```python
   driver.save_screenshot("docs/as-built/ui-description/screenshots/<screen-name>.png")
   ```
3. **View hierarchy dump**:
   ```python
   page_source = driver.page_source
   with open("docs/as-built/ui-description/hierarchies/<screen-name>.xml", "w") as f:
       f.write(page_source)
   ```
4. **Field observations** from the XML hierarchy:
   - `XCUIElementTypeTextField` / `XCUIElementTypeSecureTextField`: input field — note `label`, `value`, `name`
   - `XCUIElementTypeButton`: button — note `label`, `name`
   - `XCUIElementTypeStaticText`: label or display text
   - `XCUIElementTypeSwitch`: toggle — note label and default value
   - `XCUIElementTypePickerWheel`: picker — note label and available options
   - `XCUIElementTypeTable` / `XCUIElementTypeCollectionView`: list — capture one representative cell
   - `XCUIElementTypeNavigationBar`: note title (current screen name) and back/action buttons
5. Mark screen status: captured

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
# Screen Inventory — <App Name> (iOS)

**Captured on:** <simulator name or "real device"> running iOS <version>

| Screen | Flow / entry point | Capture status | Screenshot |
|--------|--------------------|----------------|------------|

## Not captured
- <screens not reached due to auth, scope, or navigation complexity>
```

**`screens/<screen-name>.md`:**
```markdown
# <Screen Name>

**Navigation bar title:** <title if visible>
**Flow position:** <e.g. "Onboarding — step 3 of 5">
**Screenshot:** ![<screen name>](../screenshots/<screen-name>.png)
**Hierarchy file:** [XML](../hierarchies/<screen-name>.xml)

## Fields
| Label / name | Element type | Value / placeholder | Notes |
|--------------|--------------|---------------------|-------|

## Interactive elements
| Element | Type | Action |
|---------|------|--------|

## Content structure
(Tables, collection views — describe the cell template)
```

---

## Commit (standalone use)

If this skill was invoked directly rather than through `/requirements-from-app`, commit the output following [`../../shared/commit-push-policy.md`](../../shared/commit-push-policy.md). Use commit message: `docs(as-built): capture iOS UI description — <app name>`

If invoked by `/requirements-from-app`, skip this step — that skill owns the commit.

---

## Guardrails

- Never bypass FaceID/TouchID prompts automatically — ask the user to dismiss them manually and continue
- Do not attempt to access keychain data or inspect memory — stay within the accessibility layer
- If a screen contains a WKWebView, note it as "WebView content — use `/describe-ui-from-web-app` for this section"
- Real device capture requires the user to keep the device awake and unlocked — remind them
- Do not interpret business rules — record labels and element names literally
- If Appium times out connecting to the device, check: simulator is booted (`xcrun simctl boot <name>`), Appium server is running, bundle ID is correct
