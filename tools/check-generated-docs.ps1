param(
    [string]$DocsRoot = "docs",
    [string]$ReportPath = "reports/quality-check.md"
)

$ErrorActionPreference = "Stop"

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Issues,
        [string]$Severity,
        [string]$Category,
        [string]$File,
        [int]$Line,
        [string]$Message,
        [string]$Excerpt
    )

    if ($Excerpt.Length -gt 180) {
        $Excerpt = $Excerpt.Substring(0, 177) + "..."
    }

    $Issues.Add([pscustomobject]@{
        Severity = $Severity
        Category = $Category
        File = $File
        Line = $Line
        Message = $Message
        Excerpt = $Excerpt
    })
}

function Get-RelativePath {
    param([string]$Path)

    $root = (Resolve-Path ".").Path
    $resolved = (Resolve-Path $Path).Path
    if ($resolved.StartsWith($root)) {
        return ($resolved.Substring($root.Length).TrimStart("\") -replace "\\", "/")
    }
    return $Path
}

function Get-MarkdownTableColumns {
    param([string]$Line)

    $trimmed = $Line.Trim()
    if ($trimmed.StartsWith("|")) {
        $trimmed = $trimmed.Substring(1)
    }
    if ($trimmed.EndsWith("|")) {
        $trimmed = $trimmed.Substring(0, $trimmed.Length - 1)
    }

    return ($trimmed -split "(?<!\\)\|").Count
}

function Get-Balance {
    param([string[]]$Lines, [char]$Open, [char]$Close)

    $count = 0
    foreach ($line in $Lines) {
        foreach ($char in $line.ToCharArray()) {
            if ($char -eq $Open) {
                $count++
            }
            elseif ($char -eq $Close) {
                $count--
            }
        }
    }
    return $count
}

function Test-LikelyPartialSnippet {
    param([string[]]$Lines)

    $joined = $Lines -join "`n"
    return ($joined -notmatch "^\s*<!DOCTYPE|<html|<template|<script|<style|function\s+\w+|const\s+\w+|let\s+\w+|var\s+\w+")
}

$docsRootPath = Resolve-Path $DocsRoot
$reportFullPath = Join-Path (Resolve-Path ".") $ReportPath
$reportDir = Split-Path $reportFullPath -Parent
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

$issues = New-Object System.Collections.Generic.List[object]
$mdFiles = @(Get-ChildItem -Path $docsRootPath -Recurse -Filter *.md | Sort-Object FullName)
$readme = Join-Path (Resolve-Path ".") "README.md"
if (Test-Path $readme) {
    $mdFiles = @((Get-Item $readme)) + $mdFiles
}

foreach ($file in $mdFiles) {
    $relative = Get-RelativePath $file.FullName
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
    $projectNo = $null
    $headingNumbers = @{}
    $taskNumbers = @{}
    $inFence = $false
    $fenceLang = ""
    $fenceStart = 0
    $fenceLines = New-Object System.Collections.Generic.List[string]
    $codeBlocks = New-Object System.Collections.Generic.List[object]
    $tableStart = $null
    $tableColumns = $null

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNo = $i + 1
        $line = $lines[$i]

        if ($line -match "^# Project\s+(\d+)\b") {
            $projectNo = [int]$matches[1]
        }

        if ($line -match '^```\s*(\w*)') {
            if (-not $inFence) {
                $inFence = $true
                $fenceLang = $matches[1]
                $fenceStart = $lineNo
                $fenceLines.Clear()
            }
            else {
                $inFence = $false
                $codeBlocks.Add([pscustomobject]@{
                    Lang = $fenceLang
                    Start = $fenceStart
                    End = $lineNo
                    Lines = @($fenceLines.ToArray())
                })
            }
            continue
        }

        if ($inFence) {
            $fenceLines.Add($line)
            continue
        }

        if ($line -match "<[A-Za-z!/][^>]*>") {
            Add-Issue $issues "error" "raw-html" $relative $lineNo "Raw HTML outside fenced code will be parsed by GitHub Markdown." $line
        }

        if ($line -match "!\[[^\]]*\]\(([^)]+)\)") {
            $target = $matches[1]
            if ($target -notmatch "^(https?:)?//") {
                $targetPath = Join-Path $file.DirectoryName ($target -replace "/", "\")
                if (-not (Test-Path $targetPath)) {
                    Add-Issue $issues "error" "link" $relative $lineNo "Image link target does not exist." $line
                }
            }
        }

        if ($line -match "\[[^\]]+\]\(([^)]+\.md)\)") {
            $target = $matches[1]
            if ($target -notmatch "^(https?:)?//") {
                $targetPath = Join-Path $file.DirectoryName ($target -replace "/", "\")
                if (-not (Test-Path $targetPath)) {
                    Add-Issue $issues "error" "link" $relative $lineNo "Markdown link target does not exist." $line
                }
            }
        }

        $mojibakeCodes = @(0xFFFD, 0x9225, 0x8DEF, 0x6187, 0x6A9A, 0x6A80, 0x951F)
        $hasMojibake = $false
        foreach ($code in $mojibakeCodes) {
            if ($line.IndexOf([char]$code) -ge 0) {
                $hasMojibake = $true
                break
            }
        }
        if ($hasMojibake) {
            Add-Issue $issues "error" "encoding" $relative $lineNo "Potential mojibake or replacement character." $line
        }

        if ($line -match "\bCntent\b") {
            Add-Issue $issues "warning" "spelling" $relative $lineNo "Likely typo: Cntent -> Content." $line
        }
        if ($line -cmatch "\bJavascript\b") {
            Add-Issue $issues "warning" "spelling" $relative $lineNo "Prefer standard spelling: JavaScript." $line
        }
        if ($line -match "\bhtmllang\b|<htmllang") {
            Add-Issue $issues "error" "code" $relative $lineNo "Likely missing space: <html lang=...>." $line
        }
        if ($line -match "\bimage/xicon\b") {
            Add-Issue $issues "warning" "code" $relative $lineNo "Likely MIME typo: image/x-icon." $line
        }
        if ($line -match "\b([A-Za-z]+)\s+\1\b") {
            Add-Issue $issues "warning" "grammar" $relative $lineNo "Repeated word." $line
        }
        if ($line -match "[a-z]\.[A-Z]") {
            Add-Issue $issues "info" "grammar" $relative $lineNo "Possible missing space after a period." $line
        }
        if ($line -match "^\s*\d+\.[A-Za-z]") {
            Add-Issue $issues "info" "format" $relative $lineNo "Possible missing space after numbered marker." $line
        }

        if ($projectNo -and $line -match "^## Task\s+(\d+)\.(\d+)\b") {
            $major = [int]$matches[1]
            $task = "$($matches[1]).$($matches[2])"
            if ($major -ne $projectNo) {
                Add-Issue $issues "error" "numbering" $relative $lineNo "Task number does not match project number $projectNo." $line
            }
            if ($taskNumbers.ContainsKey($task)) {
                Add-Issue $issues "warning" "numbering" $relative $lineNo "Duplicate task number $task." $line
            }
            $taskNumbers[$task] = $true
        }

        if ($projectNo -and $line -match "^###\s+(\d+)\.(\d+)\.(\d+)\b") {
            $major = [int]$matches[1]
            $section = "$($matches[1]).$($matches[2]).$($matches[3])"
            if ($major -ne $projectNo) {
                Add-Issue $issues "error" "numbering" $relative $lineNo "Section number does not match project number $projectNo." $line
            }
            if ($headingNumbers.ContainsKey($section)) {
                Add-Issue $issues "warning" "numbering" $relative $lineNo "Duplicate section number $section." $line
            }
            $headingNumbers[$section] = $true
        }

        if ($line.TrimStart().StartsWith("|")) {
            $cols = Get-MarkdownTableColumns $line
            if (-not $tableStart) {
                $tableStart = $lineNo
                $tableColumns = $cols
            }
            elseif ($cols -ne $tableColumns) {
                Add-Issue $issues "warning" "table" $relative $lineNo "Markdown table column count differs from row $tableStart." $line
            }
        }
        else {
            $tableStart = $null
            $tableColumns = $null
        }
    }

    if ($inFence) {
        Add-Issue $issues "error" "markdown" $relative $fenceStart "Unclosed fenced code block." ('```' + $fenceLang)
    }

    foreach ($block in $codeBlocks) {
        $lang = $block.Lang.ToLowerInvariant()
        $blockLines = [string[]]$block.Lines
        $joined = $blockLines -join "`n"

        if ($joined -match "<htmllang") {
            Add-Issue $issues "error" "code" $relative $block.Start "Likely missing space: <html lang=...>." ($blockLines[0])
        }
        if ($joined -match "\bconst\s+\w+\s*=\s*ref\(" -and $joined -notmatch "import\s+\{[^}]*ref") {
            Add-Issue $issues "info" "code" $relative $block.Start "Vue snippet uses ref(); ensure ref is imported in the complete file." ($blockLines[0])
        }
        if ($lang -in @("css", "js", "javascript", "vue") -and -not (Test-LikelyPartialSnippet $blockLines)) {
            $brace = Get-Balance $blockLines "{" "}"
            if ($brace -ne 0) {
                Add-Issue $issues "warning" "code" $relative $block.Start "Code block has unbalanced braces: $brace." ($blockLines[0])
            }
        }
        if ($lang -in @("js", "javascript", "vue") -and -not (Test-LikelyPartialSnippet $blockLines)) {
            $paren = Get-Balance $blockLines "(" ")"
            $bracket = Get-Balance $blockLines "[" "]"
            if ($paren -ne 0) {
                Add-Issue $issues "warning" "code" $relative $block.Start "Code block has unbalanced parentheses: $paren." ($blockLines[0])
            }
            if ($bracket -ne 0) {
                Add-Issue $issues "warning" "code" $relative $block.Start "Code block has unbalanced square brackets: $bracket." ($blockLines[0])
            }
        }
    }
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# Generated Documentation Quality Check")
$report.Add("")
$report.Add(("Scanned `{0}` Markdown files under `{1}` plus README when present." -f $mdFiles.Count, $DocsRoot))
$report.Add("")
$report.Add("This is a heuristic local check. It catches deterministic conversion, formatting, numbering, link, and common code issues; it is not a full English grammar checker or compiler.")
$report.Add("")

$report.Add("## Summary")
$report.Add("")
if ($issues.Count -eq 0) {
    $report.Add("No issues found.")
}
else {
    $issues | Group-Object Severity, Category | Sort-Object Name | ForEach-Object {
        $report.Add("- $($_.Name): $($_.Count)")
    }
}

$report.Add("")
$report.Add("## Findings")
$report.Add("")

if ($issues.Count -eq 0) {
    $report.Add("No findings.")
}
else {
    foreach ($issue in ($issues | Sort-Object @{Expression = { @{ error = 0; warning = 1; info = 2 }[$_.Severity] }}, File, Line | Select-Object -First 300)) {
        $location = "$($issue.File):$($issue.Line)"
        $report.Add("- **$($issue.Severity)** ``$($issue.Category)`` [$location] $($issue.Message)")
        if (-not [string]::IsNullOrWhiteSpace($issue.Excerpt)) {
            $report.Add("  ``$($issue.Excerpt)``")
        }
    }

    if ($issues.Count -gt 300) {
        $report.Add("")
        $report.Add("Only the first 300 findings are listed. Total findings: $($issues.Count).")
    }
}

[System.IO.File]::WriteAllLines($reportFullPath, $report, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $reportFullPath"
Write-Host "Issues: $($issues.Count)"
