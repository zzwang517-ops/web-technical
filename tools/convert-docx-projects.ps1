param(
    [string]$DocxPath = "",
    [string]$OutputRoot = "."
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-ZipEntryXml {
    param($Zip, [string]$Name)

    $entry = $Zip.GetEntry($Name)
    if (-not $entry) {
        throw "Missing entry: $Name"
    }

    $reader = New-Object System.IO.StreamReader($entry.Open())
    try {
        return [xml]$reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }
}

function New-NamespaceManager {
    param([xml]$Xml)

    $ns = New-Object System.Xml.XmlNamespaceManager -ArgumentList $Xml.NameTable
    [void]$ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
    [void]$ns.AddNamespace("r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
    [void]$ns.AddNamespace("a", "http://schemas.openxmlformats.org/drawingml/2006/main")
    return ,$ns
}

function Get-ParagraphText {
    param($Paragraph, $Ns)

    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($node in $Paragraph.SelectNodes(".//w:t | .//w:tab | .//w:br", $Ns)) {
        if ($node.LocalName -eq "tab") {
            $parts.Add("    ")
        }
        elseif ($node.LocalName -eq "br") {
            $parts.Add("`n")
        }
        else {
            $parts.Add($node.InnerText)
        }
    }

    return (($parts -join "") -replace "[`r`n]+", "`n").Trim()
}

function Get-ParagraphImageIds {
    param($Paragraph, $Ns)

    $ids = New-Object System.Collections.Generic.List[string]
    foreach ($blip in $Paragraph.SelectNodes(".//a:blip", $Ns)) {
        $id = $blip.GetAttribute("embed", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
        if ($id) {
            $ids.Add($id)
        }
    }
    return $ids
}

function Get-TableMarkdown {
    param($Table, $Ns)

    $rows = New-Object System.Collections.Generic.List[object]
    $maxCols = 0

    foreach ($tr in $Table.SelectNodes("./w:tr", $Ns)) {
        $cells = New-Object System.Collections.Generic.List[string]
        foreach ($tc in $tr.SelectNodes("./w:tc", $Ns)) {
            $cellParas = New-Object System.Collections.Generic.List[string]
            foreach ($p in $tc.SelectNodes(".//w:p", $Ns)) {
                $text = Get-ParagraphText $p $Ns
                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    $cellParas.Add((Escape-MarkdownText $text))
                }
            }
            $cell = (($cellParas -join "; ") -replace "\|", "\|")
            $cells.Add($cell)
        }
        if ($cells.Count -gt 0) {
            $rows.Add($cells)
            $maxCols = [Math]::Max($maxCols, $cells.Count)
        }
    }

    if ($rows.Count -eq 0 -or $maxCols -eq 0) {
        return @()
    }

    $lines = New-Object System.Collections.Generic.List[string]
    for ($r = 0; $r -lt $rows.Count; $r++) {
        while ($rows[$r].Count -lt $maxCols) {
            $rows[$r].Add("")
        }
    }

    $lines.Add("| " + (($rows[0] | ForEach-Object { $_ }) -join " | ") + " |")
    $lines.Add("| " + ((1..$maxCols | ForEach-Object { "---" }) -join " | ") + " |")

    for ($r = 1; $r -lt $rows.Count; $r++) {
        $lines.Add("| " + (($rows[$r] | ForEach-Object { $_ }) -join " | ") + " |")
    }

    return $lines
}

function Escape-MarkdownText {
    param([string]$Text)

    $Text = $Text -replace "\bimage/xicon\b", "image/x-icon"
    return (($Text -replace "&", "&amp;") -replace "<", "&lt;") -replace ">", "&gt;"
}

function Get-Slug {
    param([string]$Text)

    $slug = $Text.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")
    if (-not $slug) {
        return "section"
    }
    return $slug
}

function Get-ProjectFileName {
    param([int]$Number, [string]$Title)

    $withoutPrefix = $Title -replace "^Project\s+$Number\s*", ""
    $shortTitle = ($withoutPrefix -split "\s+-{2,}\s+|---")[0]
    $slug = Get-Slug $shortTitle
    return ("project-{0:00}-{1}.md" -f $Number, $slug)
}

function Test-CodeLine {
    param([string]$Text)

    $t = $Text.Trim()
    if (-not $t) {
        return $false
    }

    $patterns = @(
        '^<!DOCTYPE\b',
        '^<!--',
        '^</?[A-Za-z][A-Za-z0-9:-]*(\s|>|/>)',
        '^\{|\}$|^\}[\),;]?$',
        '^[A-Za-z_$][\w$-]*\s*:\s*(["''{\[]|.+,)$',
        '^["''][^"'']+["'']\s*:',
        '^`.*`[,;]?$',
        '^[A-Za-z_$][\w$]*(\.[A-Za-z_$][\w$]*)*\s*\(',
        '^[A-Za-z_$][\w$]*(\.[A-Za-z_$][\w$]*)*\s*=',
        '^(const|let|var|function|import|export|return|if|else|for|while|switch|case|default|break|continue|class|new|try|catch|finally|do)\b',
        '^.+;$',
        '^(document|window|console|app|router|axios|fetch|localStorage|sessionStorage|alert|confirm|prompt|Number|String|Boolean|Math|Date|setTimeout|setInterval|clearTimeout|clearInterval)\b',
        '^[*.#A-Za-z_][\w\-:#.*,\s>+~]*\s*\{',
        '^[*.#A-Za-z_][\w\-:#.*,\s>+~]*,$',
        '^[A-Za-z-]+\s*:\s*[^;]+;$',
        '^(@import|@media|@keyframes)\b',
        '^\$ npm\b|^npm\s+',
        '^[/]{2}|^/\*|^\*/',
        '^[\]\[(),;]+$'
    )

    foreach ($pattern in $patterns) {
        if ($t -cmatch $pattern) {
            return $true
        }
    }

    return $false
}

function Get-CodeLanguage {
    param([string[]]$Lines)

    $joined = $Lines -join "`n"
    if ($joined -match '<template|v-model|defineProps|createApp|\.vue') {
        return "vue"
    }
    if ($joined -match '<!DOCTYPE|<[A-Za-z!/][^>]*>') {
        return "html"
    }
    if ($joined -match '@import|@media|@keyframes|[A-Za-z-]+\s*:\s*[^;]+;') {
        return "css"
    }
    if ($joined -match '\b(const|let|var|function|=>|import|export|document\.|console\.)\b') {
        return "js"
    }
    return ""
}

function Format-MarkdownLines {
    param([object[]]$RawLines)

    $lines = New-Object System.Collections.Generic.List[string]
    $code = New-Object System.Collections.Generic.List[string]
    $inCode = $false

    function Flush-Code {
        if ($script:inCode -and $script:code.Count -gt 0) {
            $lang = Get-CodeLanguage $script:code.ToArray()
            $script:lines.Add("")
            $script:lines.Add(('```' + $lang))
            foreach ($codeLine in $script:code) {
                $script:lines.Add($codeLine)
            }
            $script:lines.Add('```')
            $script:lines.Add("")
        }
        $script:code.Clear()
        $script:inCode = $false
    }

    $script:lines = $lines
    $script:code = $code
    $script:inCode = $false

    for ($i = 0; $i -lt $RawLines.Count; $i++) {
        $item = $RawLines[$i]

        if ($item.Kind -eq "blank") {
            Flush-Code
            if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -ne "") {
                $lines.Add("")
            }
            continue
        }

        if ($item.Kind -ne "text") {
            Flush-Code
            $lines.Add($item.Value)
            continue
        }

        $text = $item.Value
        $plain = $item.Raw
        $isCode = Test-CodeLine $plain

        if (-not $isCode -and $i -gt 0 -and $i -lt ($RawLines.Count - 1)) {
            $prev = $RawLines[$i - 1]
            $next = $RawLines[$i + 1]
            if ($prev.Kind -eq "text" -and $next.Kind -eq "text" -and (Test-CodeLine $prev.Raw) -and (Test-CodeLine $next.Raw) -and $plain.Trim().Length -lt 80) {
                $isCode = $true
            }
        }

        if ($isCode) {
            $script:inCode = $true
            $script:code.Add($plain)
            continue
        }

        Flush-Code
        $lines.Add($text)
    }

    Flush-Code

    while ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq "") {
        $lines.RemoveAt($lines.Count - 1)
    }

    return $lines
}

function Copy-ProjectImage {
    param($Zip, [hashtable]$RelMap, [string]$RelId, [string]$ImageDir, [string]$ImageRelPrefix, [ref]$Counter, [hashtable]$Copied)

    if (-not $RelMap.ContainsKey($RelId)) {
        return $null
    }

    if ($Copied.ContainsKey($RelId)) {
        return $Copied[$RelId]
    }

    $target = $RelMap[$RelId]
    $entryName = if ($target.StartsWith("/")) { $target.TrimStart("/") } else { "word/$target" }
    $entryName = $entryName -replace "\\", "/"
    $entry = $Zip.GetEntry($entryName)
    if (-not $entry) {
        return $null
    }

    $ext = [System.IO.Path]::GetExtension($entryName)
    if (-not $ext) {
        $ext = ".png"
    }

    $Counter.Value++
    $fileName = "image-{0:000}{1}" -f $Counter.Value, $ext
    $destPath = Join-Path $ImageDir $fileName

    $inputStream = $entry.Open()
    try {
        $outputStream = [System.IO.File]::Create($destPath)
        try {
            $inputStream.CopyTo($outputStream)
        }
        finally {
            $outputStream.Dispose()
        }
    }
    finally {
        $inputStream.Dispose()
    }

    $relPath = "$ImageRelPrefix/$fileName"
    $Copied[$RelId] = $relPath
    return $relPath
}

if ([string]::IsNullOrWhiteSpace($DocxPath)) {
    $docx = Get-ChildItem -Path $OutputRoot -File |
        Where-Object { $_.Name -like "WorldSkills Competition Website Technology*Full-Stack Web Development.docx" } |
        Select-Object -First 1
    if (-not $docx) {
        throw "Cannot find the English Word document. Pass -DocxPath explicitly."
    }
    $docxFullPath = $docx.FullName
}
else {
    $docxFullPath = Resolve-Path $DocxPath
}
$outFullPath = Resolve-Path $OutputRoot
$docsRoot = Join-Path $outFullPath "docs"
$assetsRoot = Join-Path $outFullPath "assets\images"

New-Item -ItemType Directory -Force -Path $docsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $assetsRoot | Out-Null

$docxStream = [System.IO.File]::Open($docxFullPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$zip = New-Object System.IO.Compression.ZipArchive($docxStream, [System.IO.Compression.ZipArchiveMode]::Read, $false)
try {
    [xml]$documentXml = Read-ZipEntryXml $zip "word/document.xml"
    [xml]$relsXml = Read-ZipEntryXml $zip "word/_rels/document.xml.rels"
    $ns = New-NamespaceManager $documentXml

    $relMap = @{}
    foreach ($rel in $relsXml.Relationships.Relationship) {
        if ($rel.Type -like "*image") {
            $relMap[$rel.Id] = $rel.Target
        }
    }

    $body = $documentXml.SelectSingleNode("//w:body", $ns)
    $nodes = @($body.ChildNodes | Where-Object { $_.LocalName -eq "p" -or $_.LocalName -eq "tbl" })
    $projects = New-Object System.Collections.Generic.List[object]
    $currentPart = $null

    for ($nodeIndex = 0; $nodeIndex -lt $nodes.Count; $nodeIndex++) {
        $node = $nodes[$nodeIndex]
        if ($node.LocalName -ne "p") {
            continue
        }

        $text = Get-ParagraphText $node $ns
        if ([string]::IsNullOrWhiteSpace($text)) {
            continue
        }

        $trim = $text.Trim()
        if ($trim -match "^Part\s+(\d+)\b") {
            $partNumber = [int]$matches[1]
            $partDir = "part-{0}-{1}" -f $partNumber, (Get-Slug ($trim -replace "^Part\s+\d+\s*", ""))
            $currentPart = [pscustomobject]@{
                Number = $partNumber
                Title = $trim
                Dir = $partDir
            }
            continue
        }

        if ($currentPart -and $trim -match "^Project\s+(\d+)\b") {
            $projectNumber = [int]$matches[1]
            $projects.Add([pscustomobject]@{
                Number = $projectNumber
                Title = $trim
                Part = $currentPart
                StartIndex = $nodeIndex
                EndIndex = $nodes.Count - 1
                File = Get-ProjectFileName $projectNumber $trim
                ImageDir = ("project-{0:00}" -f $projectNumber)
                ImageRelPrefix = ("../../assets/images/project-{0:00}" -f $projectNumber)
            })
        }
    }

    for ($i = 0; $i -lt ($projects.Count - 1); $i++) {
        $projects[$i].EndIndex = $projects[$i + 1].StartIndex - 1
    }

    if ($projects.Count -eq 0) {
        throw "No project headings were found."
    }

    foreach ($project in $projects) {
        $docsDir = Join-Path $docsRoot $project.Part.Dir
        New-Item -ItemType Directory -Force -Path $docsDir | Out-Null

        $imageDir = Join-Path $assetsRoot $project.ImageDir
        New-Item -ItemType Directory -Force -Path $imageDir | Out-Null
        Get-ChildItem -Path $imageDir -File | Remove-Item -Force

        $rawLines = New-Object System.Collections.Generic.List[object]
        $inObjectives = $false
        $imageCounter = 0
        $copiedImages = @{}

        for ($nodeIndex = $project.StartIndex; $nodeIndex -le $project.EndIndex; $nodeIndex++) {
            $node = $nodes[$nodeIndex]
            $text = if ($node.LocalName -eq "p") { Get-ParagraphText $node $ns } else { "" }

            if ($node.LocalName -eq "p") {
                $imageIds = Get-ParagraphImageIds $node $ns
                foreach ($imageId in $imageIds) {
                    $relPath = Copy-ProjectImage $zip $relMap $imageId $imageDir $project.ImageRelPrefix ([ref]$imageCounter) $copiedImages
                    if ($relPath) {
                        $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "![Image]($relPath)" })
                        $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    }
                }

                if ([string]::IsNullOrWhiteSpace($text)) {
                    continue
                }

                $trim = $text.Trim()
                if ($project.Number -eq 14 -and $trim -eq "13.3.3 Task Implementation") {
                    $trim = "14.3.3 Task Implementation"
                }
                if ($project.Number -eq 5 -and $trim -eq "5.6.1 Effect Display") {
                    $trim = "5.6.2 Effect Display"
                }

                if ($trim -match '^Project\s+\d+\b') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "# $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^Task\s+\d+\.\d+\b') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "## $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^\d+\.\d+\.\d+\.?\s*') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "### $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^(Content Guid(?:e|ance)|Learning Objectives)$') {
                    $inObjectives = ($trim -eq "Learning Objectives")
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "## $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^\d+\.\s*\S' -and $trim.Length -lt 90) {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "#### $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^\(\d+\)\s+\S' -and $trim.Length -lt 120) {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "##### $(Escape-MarkdownText $trim)" })
                }
                elseif ($trim -match '^Figure\s+\d+-\d+\b') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "_$(Escape-MarkdownText $trim)_" })
                }
                elseif ($trim -match '^Table\s+\d+-\d+\b') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "**$(Escape-MarkdownText $trim)**" })
                }
                elseif ($trim -match '^Step\s+\d+:') {
                    $inObjectives = $false
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "#### $(Escape-MarkdownText $trim)" })
                }
                elseif ($inObjectives) {
                    $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = "- $(Escape-MarkdownText $trim)" })
                }
                else {
                    $rawLines.Add([pscustomobject]@{ Kind = "text"; Raw = $trim; Value = Escape-MarkdownText $trim })
                }
            }
            elseif ($node.LocalName -eq "tbl") {
                $tableLines = Get-TableMarkdown $node $ns
                if ($tableLines.Count -gt 0) {
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                    foreach ($tableLine in $tableLines) {
                        $rawLines.Add([pscustomobject]@{ Kind = "other"; Value = $tableLine })
                    }
                    $rawLines.Add([pscustomobject]@{ Kind = "blank"; Value = "" })
                }
            }
        }

        $mdLines = Format-MarkdownLines $rawLines.ToArray()
        $dest = Join-Path $docsDir $project.File
        [System.IO.File]::WriteAllLines($dest, $mdLines, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Wrote $dest"
    }

    $readme = New-Object System.Collections.Generic.List[string]
    $readme.Add("# WorldSkills Competition Website Technology")
    $readme.Add("")
    $readme.Add("Markdown learning notes generated from the English Word document.")
    $readme.Add("")
    $lastPart = -1
    foreach ($project in ($projects | Sort-Object Number)) {
        if ($project.Part.Number -ne $lastPart) {
            if ($lastPart -ne -1) {
                $readme.Add("")
            }
            $readme.Add("## $($project.Part.Title)")
            $lastPart = $project.Part.Number
        }

        $link = "docs/$($project.Part.Dir)/$($project.File)"
        $readme.Add("- [$($project.Title)]($link)")
    }

    $readmePath = Join-Path $outFullPath "README.md"
    [System.IO.File]::WriteAllLines($readmePath, $readme, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Wrote $readmePath"
}
finally {
    $zip.Dispose()
    $docxStream.Dispose()
}
