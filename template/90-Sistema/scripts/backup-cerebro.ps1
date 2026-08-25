# Empacota o que NAO sincroniza sozinho com a nuvem.
# Rode de dentro da pasta do seu Cerebro:
#   powershell -ExecutionPolicy Bypass -File 90-Sistema\scripts\backup-cerebro.ps1

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $raiz

$destino = Join-Path $raiz "90-Sistema\backups"
New-Item -ItemType Directory -Force -Path $destino | Out-Null

$carimbo = Get-Date -Format "yyyy-MM-dd"
$pacote  = Join-Path $destino "config-$carimbo.zip"

$alvos = @()
foreach ($a in @(".claude", ".gemini", ".codex", "config.yml", "CLAUDE.md", "AGENTS.md", "GEMINI.md", "90-Sistema\rotinas")) {
    $p = Join-Path $raiz $a
    if (Test-Path $p) { $alvos += $p }
}

if ($alvos.Count -eq 0) {
    Write-Host "Nada para empacotar. Voce esta na pasta certa?" -ForegroundColor Yellow
    exit 1
}

if (Test-Path $pacote) { Remove-Item $pacote -Force }
Compress-Archive -Path $alvos -DestinationPath $pacote -Force

Write-Host ""
Write-Host "  Backup pronto:" -ForegroundColor Green
Write-Host "  $pacote"
Write-Host ""
Write-Host "  Esse pacote esta numa pasta VISIVEL - entao a sua nuvem leva ele junto."
Write-Host "  Dentro dele vao as suas configuracoes e comandos, que ficam em pastas"
Write-Host "  ocultas e que muitos servicos de sincronizacao ignoram."
Write-Host ""
Write-Host "  Refaca isso sempre que mexer nas instrucoes do seu agente."
Write-Host "  Uma vez por semana ja resolve."
Write-Host ""
