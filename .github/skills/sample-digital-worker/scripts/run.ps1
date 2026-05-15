# =============================================================
# Sample Digital Worker - 実行スクリプト プレースホルダー
# =============================================================
# 使用例:
#   pwsh -File ./run.ps1 -Input "path/to/input.json"
# =============================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$InputPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "./output"
)

Write-Host "[Digital Worker] 開始" -ForegroundColor Cyan
Write-Host "  Input : $InputPath"
Write-Host "  Output: $OutputPath"

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# TODO: ここに業務ロジックを実装する
# ---------------------------------------------------------------
# 例:
#   $data = Get-Content $InputPath -Raw | ConvertFrom-Json
#   $result = $data | ForEach-Object { ... }
#   $result | ConvertTo-Json | Out-File "$OutputPath/result.json"
# ---------------------------------------------------------------

Write-Host "[Digital Worker] 完了" -ForegroundColor Green
