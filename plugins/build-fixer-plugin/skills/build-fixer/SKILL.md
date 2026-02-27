---
name: build-fixer
description: Iteratively fix build errors and lint warnings until the project compiles cleanly. Use this skill whenever the user mentions build failures, compilation errors, "fix the build", "make it compile", broken builds, CI failures related to compilation, lint errors, linting issues, "run lint", "fix lint warnings", or any variation of "the build is broken" or "fix these errors". Also trigger when the user pastes compiler output, build logs, or says things like "I'm getting errors when I build" or "can you get this to compile". Covers .NET (dotnet build), Node.js (npm/pnpm/yarn build), and other common build systems.
---

# Build Fixer

Discover how to build (or lint) the current project, run the command, and iteratively fix every error until the build is green. When something is genuinely unfixable from code alone (locked files, missing SDKs, network issues), stop and give the user a clear explanation with actionable suggestions.

## Step 1: Discover the build command

Check these sources in order — use the first one that gives a clear answer.

### 1a. Check project docs

Read CLAUDE.md and AGENTS.md (at the repo root and any nested ones) for a "how to build" or "build" section. These are the authoritative source — if they specify a command, use it exactly.

### 1b. Auto-detect from project files

If the docs don't specify a build command, look at what's in the repo root:

**Node.js / frontend projects** — Look for a lockfile to determine the package manager:
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `package-lock.json` → npm
- `bun.lockb` → bun
- No lockfile but `package.json` exists → npm (default)

Then read `package.json` and check the `scripts` section for a `build` script. The build command is `<manager> run build` (or just `<manager> build` for npm/pnpm). If there's no `build` script, check for common alternatives like `compile`, `tsc`, `webpack`, `vite build`.

**Dotnet projects** — Look for `*.sln` or `*.csproj` files.
- If a `.sln` file exists at the repo root, use `dotnet build` (it picks up the solution automatically)
- If `.sln` is in a subdirectory, use `dotnet build path/to/Solution.sln`
- If only `.csproj` files exist, use `dotnet build path/to/Project.csproj`

**.NET solution with multiple projects** — just use `dotnet build` at the solution level; it builds all projects and you'll see errors from all of them at once.

**Other ecosystems** — Check for:
- `Makefile` → `make`
- `Cargo.toml` → `cargo build`
- `go.mod` → `go build ./...`
- `build.gradle` or `build.gradle.kts` → `./gradlew build`
- `pom.xml` → `mvn compile`

### 1c. Can't figure it out

If none of the above works, tell the user:

> I couldn't determine how to build this project. Please add a "How to build" section to your AGENTS.md (or CLAUDE.md) at the repo root, something like:
>
> ```markdown
> ## How to build
> ```
> npm run build
> ```
> ```
>
> Then try again — I'll pick it up from there.

Stop here. Don't guess.

## Step 2: Run the build

Run the build command and capture the full output. For dotnet, make sure to include enough context — `dotnet build` already prints errors with file paths and line numbers, which is what you need. For Node builds, the output format varies by tool (TypeScript, webpack, vite, etc.) but errors generally include file paths.

If the build succeeds on the first try with no errors, say so and you're done. If there are warnings but no errors, skip to the "Handling warnings" section below.

## Step 3: Fix errors iteratively

Parse the build output and identify all errors. Then work through them:

### Classify each error

Most build errors fall into fixable or unfixable categories:

**Fixable from code** (go ahead and fix these):
- Type errors, missing imports, wrong method signatures
- Missing semicolons, syntax errors, malformed expressions
- Unused variable errors (if treated as errors)
- Missing interface implementations
- Incorrect generic type arguments
- Reference errors from renamed/moved symbols
- Namespace or using statement issues

**Not fixable from code** (report to user):
- Locked files (DLL locked by IIS, another process, VS)
  - Suggest: "Try stopping IIS Express / the dev server / closing Visual Studio, then retry"
- Missing SDK or runtime ("SDK not found", "framework not installed")
  - Suggest: "Install the required SDK — run `dotnet --list-sdks` to see what you have, or check the `global.json` / `.csproj` TargetFramework"
- Missing NuGet/npm packages that fail to restore (network issues, private feed auth)
  - Suggest: "Check your network connection and package source authentication. For NuGet, try `dotnet restore` manually. For npm, try `npm install`."
- Permission errors (access denied on files/directories)
  - Suggest: "Check file permissions — another process may have a lock, or you may need elevated privileges"
- Missing external tools (a build step shells out to something not installed)
  - Suggest: "Install `<tool>` — the build depends on it"

If an error is ambiguous, try to fix it. If the fix doesn't work after one attempt, reclassify it as unfixable and report it.

### Fix the fixable errors

Read the files referenced in the errors. Understand the surrounding code before making changes — don't blindly edit based on the error message alone. Fix all the errors you can identify, then re-run the build.

**Batch related errors.** If you see 15 errors all caused by the same root issue (e.g., a renamed class), fix the root cause rather than each error individually.

**Don't create new problems.** If fixing one error would require a significant refactor or changes to the public API, pause and tell the user what you've found rather than making sweeping changes. The goal is to get the build green with minimal, safe changes.

### Repeat

Run the build again. New errors may appear (previously hidden behind earlier failures, or introduced by your fixes). Keep going — fix, build, fix, build — until either:
- The build succeeds (with or without warnings), or
- Only unfixable errors remain

If you've gone through 5+ iterations and errors keep appearing or you seem to be going in circles, stop and tell the user what's happening. You might be dealing with a deeper structural issue that needs human judgment.

## Step 4: Report results

### Build succeeded
Tell the user the build is green. If you made changes, give a brief summary of what you fixed.

### Build succeeded with warnings
See "Handling warnings" below.

### Unfixable errors remain
List each unfixable error clearly:

> **Build has errors I can't fix from code:**
>
> 1. **`CS0006: Metadata file 'Foo.dll' could not be found`** — This usually means the DLL is locked or a dependency project failed to build. Try closing Visual Studio or stopping any running dev servers, then rebuild.
>
> 2. **`NETSDK1045: The current .NET SDK does not support targeting .NET 8.0`** — You need the .NET 8 SDK. Run `dotnet --list-sdks` to check what's installed, then download from https://dotnet.microsoft.com/download.

Then list what you *did* fix, so the user knows progress was made.

## Handling warnings

After a successful build, check the warning count.

- **Few warnings (< 5):** Mention them briefly. The user probably doesn't care, but let them know they're there.
- **Many warnings (5+):** Ask the user:

  > The build succeeded but there are **N warnings**. Want me to fix them too? Here's a sample:
  > - `CS8618: Non-nullable property 'Name' must contain a non-null value` (×12)
  > - `CS0168: Variable 'ex' declared but never used` (×3)
  >
  > I can work through these if you'd like, or we can leave them for now.

Wait for the user's response before touching warnings.

## Linting mode

If the user asks you to lint (or "fix lint", "run the linter", etc.), the workflow is the same but with a few differences:

### Discover the lint command

Same discovery order — CLAUDE.md/AGENTS.md first, then auto-detect:

- **Node projects:** Look for a `lint` script in package.json → `<manager> run lint`. Common linters: eslint, biome, oxlint. If no `lint` script, check for `.eslintrc*`, `biome.json`, `eslint.config.*` and suggest running the linter directly.
- **Dotnet:** `dotnet format` for code style, or check if the project uses a Roslyn analyzer configuration.
- **Python:** Look for `ruff`, `flake8`, `pylint` config files or pyproject.toml `[tool.ruff]` section.
- **Other:** Check for config files (`.prettierrc`, `rustfmt.toml`, `.golangci.yml`, etc.)

### Fix warnings AND errors

Unlike builds where you only fix errors by default, for linting fix both errors and warnings. That's the whole point of running the linter — to clean up the code. Work through them iteratively, same as build errors.

### Auto-fixable lint issues

Many linters have an auto-fix mode (`eslint --fix`, `dotnet format`, `ruff check --fix`). Try running the auto-fix first — it handles the mechanical stuff (formatting, import ordering, simple rewrites) in one pass. Then run the linter again to see what's left and fix those manually.

## Important guidelines

- **Don't break working code to fix a build.** If you're unsure whether a change is safe, ask.
- **Preserve the existing code style.** Match indentation, naming conventions, and patterns used in the file.
- **Don't add unnecessary dependencies** to fix a build error. Work with what's already in the project.
- **If the project needs a package restore first** (e.g., `dotnet restore`, `npm install`), run it before the build — but tell the user you're doing it.
- **Read before you edit.** Always read the file around the error location to understand context before making a change.
