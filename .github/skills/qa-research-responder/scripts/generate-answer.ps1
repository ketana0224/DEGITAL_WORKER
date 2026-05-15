# =============================================================
# qa-research-responder - 回答ファイル生成スクリプト
# =============================================================
# 使用例:
#   pwsh -File ./generate-answer.ps1 `
#       -QuestionId "Q001" `
#       -Question "Azure Functions のコールドスタートを抑える方法" `
#       -OutputDir "./output/answers"
# =============================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$QuestionId,

    [Parameter(Mandatory = $true)]
    [string]$Question,

    [Parameter(Mandatory = $false)]
    [string]$Category = "general",

    [Parameter(Mandatory = $false)]
    [ValidateSet("High", "Medium", "Low")]
    [string]$Confidence = "Medium",

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "./output/answers"
)

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$slug = ($Question -replace '[^\p{L}\p{N}]+', '-').Trim('-').ToLower()
if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }

$fileName = "$timestamp-$QuestionId-$slug.md"
$filePath = Join-Path $OutputDir $fileName

$templatePath = Join-Path $PSScriptRoot "../assets/answer-template.md"
if (-not (Test-Path $templatePath)) {
    Write-Error "テンプレートが見つかりません: $templatePath"
    exit 1
}

$content = Get-Content $templatePath -Raw
$content = $content -replace '\{\{QID\}\}', $QuestionId
$content = $content -replace '\{\{質問文\}\}', $Question
$content = $content -replace '\{\{category\}\}', $Category
$content = $content -replace '\{\{YYYY-MM-DD HH:mm\}\}', (Get-Date -Format "yyyy-MM-dd HH:mm")
$content = $content -replace '\{\{High / Medium / Low\}\}', $Confidence

Set-Content -Path $filePath -Value $content -Encoding UTF8
Write-Host "[qa-research-responder] 生成完了: $filePath" -ForegroundColor Green

# 生成したパスを呼び出し元に返す
return $filePath
