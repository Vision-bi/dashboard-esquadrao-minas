# ============================================================
# Script: atualizar_github.ps1
# Função: Atualiza o repositório do painel Esquadrão Minas
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "=== Atualizando repositório do painel Esquadrão Minas ===" -ForegroundColor Cyan
Set-Location "C:\Vision\dashboard_esquadrao"

# 1️⃣ Ativa o ambiente virtual (se existir)
if (-not ($env:VIRTUAL_ENV)) {
    $venvPath = "C:\Vision\dashboard_esquadrao\venv\Scripts\Activate.ps1"
    if (Test-Path $venvPath) {
        Write-Host "Ativando ambiente virtual..." -ForegroundColor Yellow
        & $venvPath
    } else {
        Write-Host "Aviso: ambiente virtual não encontrado em $venvPath" -ForegroundColor Yellow
    }
}

# 2️⃣ Exibe o status do repositório
Write-Host "`nVerificando status do repositório..." -ForegroundColor DarkCyan
git status

# 3️⃣ Adiciona alterações
git add .

# 4️⃣ Verifica se há algo a commitar
$hasChanges = (git status --porcelain)
if (-not $hasChanges) {
    Write-Host "`nNenhuma alteração detectada. O repositório já está atualizado." -ForegroundColor Yellow
    exit 0
}

# 5️⃣ Pede mensagem de commit
$mensagem = Read-Host "Digite uma mensagem de commit (pressione Enter para usar a padrão)"
if ([string]::IsNullOrWhiteSpace($mensagem)) {
    $mensagem = "Atualização automática do painel Esquadrão Minas"
}

git commit -m $mensagem | Out-Null

# 6️⃣ Faz o push para o GitHub
Write-Host "`nEnviando alterações para o GitHub..." -ForegroundColor Yellow
$pushResult = git push origin principal 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao enviar para o GitHub:" -ForegroundColor Red
    Write-Host $pushResult -ForegroundColor DarkRed
    exit 1
}

Write-Host "Push realizado com sucesso para a branch principal!" -ForegroundColor Green

# 7️⃣ Solicita atualização no Streamlit Cloud
Write-Host "`nVerificando atualização no Streamlit Cloud..." -ForegroundColor Yellow
$url = "https://dashboard-esquadrao-minas.streamlit.app/"

try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Streamlit respondeu com sucesso (HTTP 200)!" -ForegroundColor Green
    } else {
        Write-Host "Streamlit respondeu com código $($response.StatusCode). O app deve atualizar em breve." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Push feito, mas o Streamlit pode levar até 1 minuto para atualizar automaticamente." -ForegroundColor Yellow
}

# 8️⃣ Finalização
Write-Host "`nProcesso concluído com sucesso! Painel e repositório sincronizados." -ForegroundColor Green
Write-Host "==============================================================="
