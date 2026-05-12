#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Automates git workflow: pull, add, commit, and push with AI-generated commit messages.

.DESCRIPTION
  Executes a complete git workflow: pull latest changes, stage all modifications,
  commit with an optional AI-generated message, and push to remote.

  The script can automatically stash local changes before pulling if needed,
  and supports AI-powered commit message generation using the GitHub Copilot CLI.

.PARAMETER Message
  The commit message. If not provided and -NoAI is not specified, an AI-generated
  message will be created based on the staged changes.

.PARAMETER RequireConfirmation
  Show a confirmation prompt before committing. By default, commits without confirmation.

.PARAMETER NoAI
  Disable AI-generated commit messages. If -Message is not provided, the user
  will be prompted to enter a message manually.

.PARAMETER ShowDebug
  Enable verbose debugging output for AI operations.

.PARAMETER Model
  The AI model to use for commit message generation. Default is 'gpt-5-mini'.
  Valid options: 'claude-sonnet-4.5', 'claude-haiku-4.5', 'claude-opus-4.5', 'claude-sonnet-4',
  'gpt-5.1-codex-max', 'gpt-5.1-codex', 'gpt-5.2', 'gpt-5.1', 'gpt-5', 'gpt-5.1-codex-mini',
  'gpt-5-mini', 'gpt-4.1', 'gemini-3-pro-preview'

.PARAMETER MaxPatchChars
  Maximum number of characters from the git diff to include in the AI prompt.
  Default is 12000.

.EXAMPLE
  .\git-auto-commit.ps1 -Message "feat: add user authentication"
  Commits staged changes with the specified message.

.EXAMPLE
  .\git-auto-commit.ps1
  Generates an AI commit message and commits without confirmation (default behavior).

.EXAMPLE
  .\git-auto-commit.ps1 -RequireConfirmation
  Generates an AI commit message and shows confirmation before committing.

.EXAMPLE
  .\git-auto-commit.ps1 -NoAI
  Stages and commits changes, prompting for commit message.

.EXAMPLE
  .\git-auto-commit.ps1 -LoopMinutes 5
  Runs continuously, checking for changes every 5 minutes.

.NOTES
  Requires git to be installed and available in PATH.
  AI generation requires GitHub Copilot CLI or compatible tool.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Message,

    [Parameter()]
    [switch]$RequireConfirmation,

    [Parameter()]
    [switch]$NoAI,

    [Parameter()]
    [switch]$ShowDebug,

    [Parameter()]
    [ValidateRange(100, 50000)]
    [int]$MaxPatchChars = 12000,

    [Parameter()]
    [ValidateSet('claude-sonnet-4.5', 'claude-haiku-4.5', 'claude-opus-4.5', 'claude-sonnet-4', 'gpt-5.1-codex-max', 'gpt-5.1-codex', 'gpt-5.2', 'gpt-5.1', 'gpt-5', 'gpt-5.1-codex-mini', 'gpt-5-mini', 'gpt-4.1', 'gemini-3-pro-preview')]
    [string]$Model = 'gpt-5-mini',

    [Parameter()]
    [ValidateRange(1, 1440)]
    [int]$LoopMinutes,

    [Parameter()]
    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "git-auto-commit — Pull, stage, commit (with AI message), and push in one step." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -Message <string>       Commit message (skips AI generation)"
    Write-Host "  -NoAI                   Disable AI; prompt for message manually"
    Write-Host "  -Model <name>           AI model to use (default: gpt-5-mini)"
    Write-Host "  -MaxPatchChars <int>    Max diff chars sent to AI (default: 12000)"
    Write-Host "  -RequireConfirmation    Prompt before committing"
    Write-Host "  -LoopMinutes <int>      Run continuously every N minutes (1-1440)"
    Write-Host "  -ShowDebug              Show verbose AI diagnostics"
    Write-Host "  -Help                   Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host '  .\git-auto-commit.ps1                          # AI commit + push'
    Write-Host '  .\git-auto-commit.ps1 -Message "fix: typo"     # Manual message'
    Write-Host '  .\git-auto-commit.ps1 -LoopMinutes 5           # Auto-commit every 5 min'
    Write-Host ""
    return
}

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    <#
    .SYNOPSIS
        Executes a git command and throws an error if it fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    Write-Verbose "Executing: git $($Arguments -join ' ')"
    
    $output = & git @Arguments 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        $errorMessage = "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
        if ($output) {
            $errorMessage += "`nOutput: $output"
        }
        throw $errorMessage
    }
    
    return $output
}

function Get-GitRepositoryRoot {
    <#
    .SYNOPSIS
        Gets the root directory of the current git repository.
    #>
    [CmdletBinding()]
    param()

    try {
        $root = & git rev-parse --show-toplevel 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Not in a git repository: $root"
        }
        return $root.Trim()
    }
    catch {
        throw "Failed to get repository root: $_"
    }
}

function Test-GitWorkingTreeDirty {
    <#
    .SYNOPSIS
        Tests if the git working tree has uncommitted changes.
    #>
    [CmdletBinding()]
    param()

    $status = & git status --porcelain 2>&1
    return [bool]$status
}

function ConvertTo-CleanCommitMessage {
    <#
    .SYNOPSIS
        Cleans and normalizes AI-generated commit message output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text
    )

    $cleanText = $Text.Trim()
    
    if (-not $cleanText) {
        return $null
    }

    # Remove markdown code fences
    $cleanText = $cleanText -replace '```[a-zA-Z0-9_-]*', '' -replace '```', ''

    # Remove surrounding quotes
    $cleanText = $cleanText.Trim('"', "'")

    # Remove common AI output prefixes
    $cleanText = $cleanText -replace '^(commit message:|message:|subject:)\s*', ''

    # Get first non-empty line
    $lines = @($cleanText -split '\r?\n' | 
        ForEach-Object { $_.Trim() } | 
        Where-Object { $_ })
    
    if ($lines.Count -gt 0) {
        return $lines[0]
    }

    return $null
}

function Invoke-AICommitMessage {
    <#
    .SYNOPSIS
        Generates a commit message using AI based on staged changes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [Parameter(Mandatory)]
        [string]$ModelName,

        [Parameter()]
        [switch]$EnableDebug
    )

    # Get AI command from environment or use default
    $aiCommand = $env:GIT_AUTO_COMMIT_AI_COMMAND
    if (-not $aiCommand) {
        $aiCommand = 'copilot'
    }

    Write-Host "[AI] Checking for command: $aiCommand" -ForegroundColor DarkGray

    # Check if command exists
    $commandInfo = Get-Command $aiCommand -ErrorAction SilentlyContinue
    if (-not $commandInfo) {
        $errorMsg = "AI command '$aiCommand' not found. Install GitHub Copilot CLI (https://github.com/github/cli) or set GIT_AUTO_COMMIT_AI_COMMAND environment variable.`n   Ensure copilot CLI is in PATH or use: \$env:GIT_AUTO_COMMIT_AI_COMMAND = 'path\\to\\copilot'"
        Write-Host "❌ $errorMsg" -ForegroundColor Red
        return $null
    }

    if ($EnableDebug) {
        Write-Host "`n[AI Debug] Command found: $aiCommand" -ForegroundColor Cyan
        Write-Host "[AI Debug] Location: $($commandInfo.Source)" -ForegroundColor Cyan
        Write-Host "[AI Debug] Model: $ModelName" -ForegroundColor Cyan
        Write-Host "[AI Debug] Prompt length: $($Prompt.Length) characters" -ForegroundColor Cyan
    }

    # Build arguments for copilot CLI
    # Note: When splatting to a native executable, PowerShell automatically quotes arguments with spaces
    $arguments = @(
        '--model',
        $ModelName,
        '--silent',
        '-p',
        $Prompt
    )

    try {
        if ($EnableDebug) {
            Write-Host "[AI Debug] Full command: $aiCommand --model $ModelName --silent -p `"[prompt:$($Prompt.Length) chars]`"" -ForegroundColor Cyan
            Write-Host "[AI Debug] Timeout: 60 seconds" -ForegroundColor Cyan
        }

        Write-Host "[AI] Invoking: copilot" -ForegroundColor DarkGray

        if ($EnableDebug) {
            Write-Host "[AI Debug] Arguments: model=$ModelName, silent=true, prompt_length=$($Prompt.Length)" -ForegroundColor DarkGray
        }

        try {
            # Invoke copilot directly using PowerShell's & operator
            # This is the most reliable way to handle complex arguments
            $result = & copilot --model $ModelName --silent -p $Prompt 2>&1
            $exitCode = $LASTEXITCODE

            if ($exitCode -eq 0) {
                $response = if ($result -is [array]) { $result -join "`n" } else { $result }
                $errorOutput = ''
            } else {
                $response = ''
                $errorOutput = if ($result -is [array]) { $result -join "`n" } else { $result }
            }
        }
        catch {
            $exitCode = 1
            $response = ''
            $errorOutput = $_.Exception.Message
        }

        if ($EnableDebug) {
            Write-Host "[AI Debug] Exit code: $exitCode" -ForegroundColor Cyan
            $preview = $response.Trim()
            if ($preview.Length -gt 500) {
                $preview = $preview.Substring(0, 500) + "`n... [truncated]"
            }
            Write-Host "[AI Debug] Raw response:`n$preview" -ForegroundColor DarkGray
            if ($errorOutput) {
                Write-Host "[AI Debug] Error output:`n$errorOutput" -ForegroundColor DarkGray
            }
        }

        if ($exitCode -ne 0) {
            Write-Host "❌ AI command failed with exit code $exitCode" -ForegroundColor Red
            if ($response.Trim()) {
                Write-Host "   Response: $($response.Trim())" -ForegroundColor Red
            }
            if ($errorOutput.Trim()) {
                Write-Host "   Error: $($errorOutput.Trim())" -ForegroundColor Red
            }
            Write-Host "   Try running: `copilot --help` to diagnose" -ForegroundColor Yellow
            return $null
        }

        # Clean and return the message
        $cleanMessage = ConvertTo-CleanCommitMessage -Text $response

        if ($EnableDebug -and $cleanMessage) {
            Write-Host "[AI Debug] Cleaned message: '$cleanMessage'" -ForegroundColor Green
        }

        return $cleanMessage
    }
    catch {
        Write-Host "❌ AI invocation failed: $_" -ForegroundColor Red
        if ($EnableDebug) {
            Write-Host "[AI Debug] Exception: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "[AI Debug] Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
        }
        return $null
    }
}

function Invoke-GitAutoCommitIteration {
    <#
    .SYNOPSIS
        Executes a single iteration of the git auto-commit workflow.
    .OUTPUTS
        Returns $true if successful, $false otherwise.
    #>
    [CmdletBinding()]
    param(
        [string]$CommitMessage,
        [switch]$UseNoAI,
        [switch]$UseRequireConfirmation,
        [switch]$UseShowDebug,
        [int]$PatchMaxChars,
        [string]$AIModel
    )

    $originalLocation = Get-Location

    try {
        # Navigate to repository root
        $repositoryRoot = Get-GitRepositoryRoot
        Set-Location $repositoryRoot
        Write-Verbose "Repository root: $repositoryRoot"

        # Get current branch name
        $currentBranch = & git rev-parse --abbrev-ref HEAD 2>&1
        if ($LASTEXITCODE -ne 0) {
            $currentBranch = "(unknown)"
        }

        Write-Host "`n=== Git Auto Commit ===" -ForegroundColor Cyan
        Write-Host "Repository: $repositoryRoot" -ForegroundColor Gray
        Write-Host "Branch: $currentBranch`n" -ForegroundColor Gray

        # Step 1: Pull latest changes
        Write-Host "⬇️  Pulling latest changes..." -ForegroundColor Yellow
        try {
            Invoke-Git -Arguments @('pull') | Out-Null
            Write-Host "    ✓ Pull completed`n" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to pull changes. Resolve conflicts and try again. Error: $_" -ForegroundColor Red
            return $false
        }

        # Step 2: Stage all changes
        Write-Host "📝 Staging all changes..." -ForegroundColor Yellow
        Invoke-Git -Arguments @('add', '.') | Out-Null
        Write-Host "    ✓ Changes staged`n" -ForegroundColor Green

        # Step 3: Check if there are changes to commit
        $null = & git diff --cached --quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ No changes to commit" -ForegroundColor Green
            return $true
        }

        # Step 4: List changed files
        Write-Host "📂 Changed files:" -ForegroundColor Cyan
        $changedFilesList = & git diff --cached --name-status
        foreach ($file in $changedFilesList) {
            Write-Host "    $file" -ForegroundColor Gray
        }
        Write-Host ""

        # Step 5: Get or generate commit message
        $finalMessage = $CommitMessage

        if (-not $finalMessage -and -not $UseNoAI) {
            Write-Host "🤖 Generating commit message with AI..." -ForegroundColor Yellow
            if ($UseShowDebug) {
                Write-Host "   (Run with -ShowDebug for detailed AI diagnostics)" -ForegroundColor DarkGray
            }

            # Get git diff information for AI prompt
            $changedFiles = (& git diff --cached --name-status | Out-String).Trim()
            $diffStat = (& git diff --cached --stat | Out-String).Trim()
            $diffPatch = & git diff --cached | Out-String

            if ($diffPatch.Length -gt $PatchMaxChars) {
                $diffPatch = $diffPatch.Substring(0, $PatchMaxChars) + "`n... [truncated at $PatchMaxChars characters]"
            }

            # Build AI prompt
            $aiPrompt = @"
Generate a concise git commit message for these staged changes.

Rules:
- Output ONLY the commit message subject line
- Use Conventional Commits format when appropriate (feat:, fix:, chore:, docs:, refactor:, test:)
- Maximum 100 characters
- Be specific and descriptive

Changed files:
$changedFiles

Diff statistics:
$diffStat

Diff content:
$diffPatch
"@

            $finalMessage = Invoke-AICommitMessage -Prompt $aiPrompt -ModelName $AIModel -EnableDebug:$UseShowDebug

            if ($finalMessage) {
                Write-Host "    ✓ AI generated message`n" -ForegroundColor Green
            }
            else {
                Write-Host "    ⚠️  AI generation failed or unavailable" -ForegroundColor Yellow
                Write-Host "    Tip: Run with -ShowDebug for detailed diagnostics`n" -ForegroundColor Yellow
            }
        }

        # Step 6: Prompt for message if still empty
        if (-not $finalMessage) {
            Write-Host "💬 Enter commit message:" -ForegroundColor Yellow
            $finalMessage = Read-Host "   "
            $finalMessage = ($finalMessage | ConvertTo-CleanCommitMessage)
        }

        # Validate commit message
        if (-not $finalMessage) {
            Write-Host "❌ Commit message cannot be empty" -ForegroundColor Red
            return $false
        }

        # Step 7: Display message and confirm
        Write-Host "📋 Commit message:" -ForegroundColor Cyan
        Write-Host "    $finalMessage`n" -ForegroundColor White

        if ($UseRequireConfirmation) {
            $confirmation = Read-Host "Commit? (y/n)"
            if ($confirmation -ne 'y') {
                Write-Host "`n❌ Operation cancelled" -ForegroundColor Yellow
                return $false
            }
            Write-Host ""
        }

        # Step 8: Commit changes
        Write-Host "💾 Creating commit..." -ForegroundColor Yellow
        Invoke-Git -Arguments @('commit', '-m', $finalMessage) | Out-Null
        Write-Host "    ✓ Commit created`n" -ForegroundColor Green

        # Step 9: Push changes
        Write-Host "⬆️  Pushing to remote..." -ForegroundColor Yellow
        try {
            Invoke-Git -Arguments @('push') | Out-Null
            Write-Host "    ✓ Push completed`n" -ForegroundColor Green
        }
        catch {
            Write-Warning "Push failed: $_"
            Write-Host "`n⚠️  Commit created locally but push failed. Run 'git push' manually.`n" -ForegroundColor Yellow
            return $false
        }

        Write-Host "✅ Done!`n" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Git auto-commit failed: $_" -ForegroundColor Red
        if ($_.Exception.StackTrace) {
            Write-Verbose "Stack trace: $($_.Exception.StackTrace)"
        }
        return $false
    }
    finally {
        Set-Location $originalLocation
    }
}

# Main Script
$iterationParams = @{
    CommitMessage          = $Message.Trim()
    UseNoAI                = $NoAI
    UseRequireConfirmation = $RequireConfirmation
    UseShowDebug           = $ShowDebug
    PatchMaxChars          = $MaxPatchChars
    AIModel                = $Model
}

if ($LoopMinutes) {
    Write-Host "`n🔄 Starting continuous mode (every $LoopMinutes minute$(if ($LoopMinutes -ne 1) { 's' }))" -ForegroundColor Cyan
    Write-Host "   Press Ctrl+C to stop`n" -ForegroundColor DarkGray

    $iteration = 0

    while ($true) {
        $iteration++
        $currentTime = Get-Date
        $nextRunTime = $currentTime.AddMinutes($LoopMinutes)

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Iteration #$iteration at $($currentTime.ToString('yyyy-MM-dd HH:mm:ss')) | Next run at $($nextRunTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Magenta
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        $null = Invoke-GitAutoCommitIteration @iterationParams

        Write-Host "`n⏳ Waiting $LoopMinutes minute$(if ($LoopMinutes -ne 1) { 's' }) until next check..." -ForegroundColor DarkGray
        Start-Sleep -Seconds ($LoopMinutes * 60)
    }
}
else {
    # Single run mode
    $null = Invoke-GitAutoCommitIteration @iterationParams
    Write-Host "Tip: Use -LoopMinutes <N> to auto-commit every N minutes." -ForegroundColor DarkGray
}
