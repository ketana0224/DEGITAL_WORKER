# =============================================================
# qa-answer-reviewer - レビューレポート生成スクリプト
# =============================================================
# 使用例:
#   # 単一ファイル
#   pwsh -File ./run-review.ps1 -Target "./output/answers/Q001.md"
#
#   # ディレクトリ一括
#   pwsh -File ./run-review.ps1 -Target "./output/answers" -Batch
# =============================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Target,

    [Parameter(Mandatory = $false)]
    [switch]$Batch,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "./output/reviews",

    [Parameter(Mandatory = $false)]
    [switch]$InternalOnly
)

if (-not (Test-Path $Target)) {
    Write-Error "対象が見つかりません: $Target"
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmm"

function New-ReviewFromTemplate {
    param(
        [string]$AnswerFile,
        [string]$TemplatePath,
        [string]$OutPath
    )

    if (-not (Test-Path $TemplatePath)) {
        Write-Error "テンプレートが見つかりません: $TemplatePath"
        return
    }

    $qid = ([IO.Path]::GetFileNameWithoutExtension($AnswerFile) -split '-')[0]
    $now = Get-Date -Format "yyyy-MM-dd HH:mm"

    $content = Get-Content $TemplatePath -Raw
    $content = $content -replace '\{\{QID\}\}', $qid
    $content = $content -replace '\{\{answer-file\}\}', ([IO.Path]::GetFileName($AnswerFile))
    $content = $content -replace '\{\{answer-file-path\}\}', $AnswerFile
    $content = $content -replace '\{\{YYYY-MM-DD HH:mm\}\}', $now

    Set-Content -Path $OutPath -Value $content -Encoding UTF8
    Write-Host "[qa-answer-reviewer] レビュー雛形を生成: $OutPath" -ForegroundColor Green
}

$singleTemplate = Join-Path $PSScriptRoot "../assets/review-report-template.md"
$batchTemplate  = Join-Path $PSScriptRoot "../assets/batch-review-template.md"

if ($InternalOnly) {
    Write-Host "[mode] internal-only: 外部 URL の検証はスキップします" -ForegroundColor Yellow
}

if ($Batch -or (Get-Item $Target).PSIsContainer) {
    $files = Get-ChildItem -Path $Target -Filter "*.md" -File
    Write-Host "[qa-answer-reviewer] 一括レビュー対象: $($files.Count) 件" -ForegroundColor Cyan

    foreach ($f in $files) {
        $outFile = Join-Path $OutputDir "$timestamp-$($f.BaseName)-review.md"
        New-ReviewFromTemplate -AnswerFile $f.FullName -TemplatePath $singleTemplate -OutPath $outFile
    }

    $batchOut = Join-Path $OutputDir "$timestamp-batch-review.md"
    $batch = Get-Content $batchTemplate -Raw
    $batch = $batch -replace '\{\{YYYY-MM-DD HH:mm\}\}', (Get-Date -Format "yyyy-MM-dd HH:mm")
    $batch = $batch -replace '\{\{target-dir\}\}', $Target
    $batch = $batch -replace '\{\{N\}\}', $files.Count
    Set-Content -Path $batchOut -Value $batch -Encoding UTF8
    Write-Host "[qa-answer-reviewer] 一括サマリ: $batchOut" -ForegroundColor Green
}
else {
    $base = [IO.Path]::GetFileNameWithoutExtension($Target)
    $outFile = Join-Path $OutputDir "$timestamp-$base-review.md"
    New-ReviewFromTemplate -AnswerFile $Target -TemplatePath $singleTemplate -OutPath $outFile
}
