---
name: android-key-signer
description: "Diagnostic and advisory skill for Android app-signing health. Inspects keystores, audits git hygiene, reviews the release pipeline, runs a pre-upload preflight, and diagnoses Play 'wrong key' rejections. Read-only on key material; never performs destructive Play Console actions — it tells the human exactly what to do. Use when the user says 'check signing', 'signing health', 'wrong key', 'upload key', 'keystore audit', 'Play rejected my build', 'pre-upload check', or wants to verify Android release-signing setup."
---

# Android signing health — diagnostic and advisory

Produces a one-screen **Key Health Report** covering keystores, git hygiene, pipeline configuration, and (optionally) a pre-upload preflight. Advisory only — human steps are clearly marked.

## Three keys (reference table — never confuse these)

| Key | Owner | Where | Purpose | Touch it? |
|-----|-------|-------|---------|-----------|
| **App-signing key** | Google (Play App Signing) | Google's servers | Re-signs the APK users download | Never — Google holds it |
| **Upload key** | Developer | Outside the repo (provided via CI secret) | Signs bundles you upload to Play; first upload permanently sets it | Sign builds; guard the file |
| **Sideload key** | Developer | `keystore/sideload.jks` — committed on purpose | Signs the sideload APK so direct installs upgrade in place | Never upload to Play |

The incident this skill exists to prevent: `KEYSTORE_FILE` unset → Gradle silently fell back to the sideload key → sideload-signed AAB uploaded first → Play locked the upload key to the **wrong** key. Fix required an upload-key reset (1–2 business days).

---

## Workflow

### Step 1 — Locate and identify every keystore

Find all keystores in the repo and common external locations:

```bash
# In-repo keystores
find . -name '*.jks' -o -name '*.keystore' 2>/dev/null

# Common external locations
ls ~/keys/*.jks ~/keys/*.keystore ~/.android/*.jks ~/.android/*.keystore 2>/dev/null
```

For each reachable keystore, inspect it (prompt the user for the password only if they supply one; never echo it):

```bash
keytool -list -v -keystore <file> -storepass <password>
# Records: alias, SHA1, SHA256, validity dates
```

**Classify each keystore:**
- **Upload key** — real private key, lives outside the repo, used for Play uploads.
- **Sideload throwaway** — committed inside the repo, used only for direct-install APKs.
- **Unknown** — inspect and ask the user.

**Flag** any real (non-sideload) private key found inside the repo working tree. It is one `git clean -fdx` away from permanent loss. Recommend: move it outside the repo tree and create an encrypted backup.

---

### Step 2 — Git hygiene

Check `.gitignore` rules:

```bash
cat .gitignore | grep -E 'jks|keystore|pem'
```

Verify the three expected rules are present and intentional:
- `*.jks` — real keys ignored.
- `!keystore/sideload.jks` — sideload exception (committed by design in a private repo).
- `*.pem` — certificates ignored.

Confirm each keystore's tracked/ignored status:

```bash
git check-ignore -v keystore/sideload.jks
git check-ignore -v <upload-key-path>

# Prove no private key is tracked
git ls-files | grep -iE '\.(jks|keystore|pem)$'
```

**Scan git history** for any key that was ever committed:

```bash
git log --all --full-history -- '*.jks' '*.keystore' '*.pem'
```

If a **real (non-sideload) private key** appears in history, treat it as **compromised**. Recommend: generate a new key and request an upload-key reset to the new key. Rotating the password alone is insufficient once a private key is in git history.

Also note (but don't fail on) whether `local.properties` and `.gradle/` are gitignored.

---

### Step 3 — Pipeline audit

Read the Gradle signing config:

```bash
cat app/build.gradle.kts | grep -A 20 'signingConfigs\|release'
```

Read the release workflow:

```bash
cat .github/workflows/release*.yml .github/workflows/build*.yml 2>/dev/null
```

Verify:
1. The release build uses the upload signing config when `KEYSTORE_FILE` is present.
2. The fallback to the sideload config emits a visible `::warning::` — a **silent** fallback is the incident vector.
3. CI decodes `KEYSTORE_FILE` (base64 → file), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` before the Gradle build.
4. The AAB is attached to the GitHub Release.
5. Play upload only occurs when the Play service-account secret is set — a missing secret must not silently skip the upload or upload the wrong artifact.

**Flag** any code path where a sideload-signed or unsigned AAB could reach Play unnoticed.

---

### Step 4 — Pre-upload preflight

Given a built `.aab` or `.apk`, extract its signing certificate fingerprint and compare it to the expected upload key before uploading.

**Extract fingerprint from an AAB/APK:**

```bash
# Preferred — apksigner
apksigner verify --print-certs <file.apk>

# Fallback — unzip + keytool
unzip -p <file.apk> META-INF/*.RSA | keytool -printcert
```

**Compare to the upload key:**

```bash
keytool -list -v -keystore <upload.jks> -alias <alias> -storepass <password> \
  | grep -i SHA1
```

If the fingerprints **match** → safe to upload.

If they **do not match** → **block with a loud error.** Surface expected vs. actual SHA1, identify which key was used, and route to Step 5.

> ⚠️ **First-upload rule:** The very first AAB uploaded to a brand-new Play app permanently sets the upload key. Run this preflight before every first upload.

---

### Step 5 — Mismatch diagnosis and remediation

Parse a Play "Android App Bundle is signed with the wrong key" rejection.

Extract the expected and actual SHA1 from the error message or Play Console, then map each to a known key using `keytool`.

```
DECISION TREE
─────────────
Artifact signed with sideload/throwaway key (SHA1 matches sideload.jks)?
  └─ YES → Rebuild with real upload key (set KEYSTORE_FILE), re-upload.
           Root cause: KEYSTORE_FILE was unset; Gradle fell back to sideload.

Play's recorded upload key is wrong (e.g. locked on a sideload key from first upload),
but the artifact itself uses the correct real key?
  └─ YES → Request an upload-key reset:
           1. Export the real upload key's certificate:
              keytool -export -rfc \
                -alias <alias> -keystore <real.jks> \
                -file upload_certificate.pem
           2. Play Console → Test and release → App integrity →
              Play app signing → Upload key certificate →
              "Request upload key reset" → upload upload_certificate.pem.
           3. Google enables the reset in ~1–2 business days.
           4. Delete upload_certificate.pem locally after submission.

Neither situation above?
  └─ Describe the mismatch to the user and ask for more context.
```

**NEVER recommend "Change app signing key"** — that button is destructive: it invalidates all previously uploaded versions and forces every tester to uninstall and reinstall. It is the wrong fix for an upload-key mismatch.

---

### Step 6 — Report and offer fixes

Output a prioritised **Key Health Report**:

```
## Android Key Health Report

### Keystores found
[table: file | alias | SHA1 | classification | location-risk]

### Git hygiene
[✅/⚠️/❌ for each check]

### Pipeline
[✅/⚠️/❌ for each check]

### Pre-upload preflight
[✅ match / ❌ MISMATCH — details]

### Findings (prioritised)
P0 — [blocking / data-loss risk]
P1 — [should fix before next release]
P2 — [recommended improvements]

### Human-only actions required
[explicit step-by-step for anything that needs a human]
```

**Auto-apply** only safe, reversible things: add missing `.gitignore` rules with the user's confirmation.

**Never auto-apply**: key moves, backups, Play Console actions, password changes, git history rewrites.

---

## Guardrails

- **Read-only on key material.** Never print private-key bytes. Never echo passwords. Never commit any `.jks`/`.pem`. Never move or delete a keystore without explicit user confirmation.
- **Never recommend "Change app signing key"** for an upload-key mismatch — it is destructive and the wrong fix.
- **The committed sideload key is non-secret by design** in a private repo. Do not alarm the user about it being committed; do verify it is never uploaded to Play.
- **A real private key in git history = compromised.** Recommend a full rotation (new key + upload-key reset), not a password change.
- **Never touch Google's app-signing key.** It lives on Google's servers; the developer has no access and needs none.
- **All SHA1/SHA256 values are re-derived each run** via `keytool`. Do not hardcode fingerprints — verify them live.
