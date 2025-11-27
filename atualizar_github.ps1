# FILE: atualizar_github.ps1
# ---------------------------------------------------------------
# 🚀 Atualizar GitHub + Backup Automático + Rodar Streamlit
# Projeto: Dashboard Esquadrão Minas
# ---------------------------------------------------------------

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== 🚀 Atualizando repositório do painel Esquadrão Minas ===" -ForegroundColor Cyan

# ---------------------------------------------------------------
# 📦 BACKUP AUTOMÁTICO
# ---------------------------------------------------------------
$projeto = "C:\Vision\dashboard_esquadrao"
$backupDir = Join-Path $projeto "backups"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$data = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "backup_esquadrao_$data.zip"

Write-Host "`n🗂️ Criando backup do projeto..." -ForegroundColor Yellow

# Arquivos válidos para backup (exclui venv, .git, backups, logs)
$excluir = @("venv", ".git", "backups", "__pycache__", ".streamlit", "*.log")

$arquivos = Get-ChildItem -Path $projeto -Recurse -File |
    Where-Object {
        $fullName = $_.FullName.ToLower()
        $permitido = $true

        foreach ($ex in $excluir) {
            if ($fullName -like "*$ex*") { $permitido = $false; break }
        }

        # Apenas tipos relevantes
        $permitido -and ($_.Extension -match "^\.(py|ps1|json|txt|html|css|js|png|ico|xlsx|csv|md)$")
    }

Compress-Archive -Path $arquivos.FullName -DestinationPath $backupFile -Force
Write-Host "✅ Backup criado com sucesso:`n$backupFile" -ForegroundColor Green


# ---------------------------------------------------------------
# 🔧 GIT - ATUALIZAÇÃO
# ---------------------------------------------------------------
Write-Host "`n📂 Verificando status do repositório..." -ForegroundColor Cyan
git status


# Adicionar somente arquivos úteis
Write-Host "`n📄 Adicionando alterações..." -ForegroundColor Yellow
git add *.py *.json *.ps1 *.png *.ico *.txt *.html *.css *.js *.csv *.md *.xlsx


# Commit
$mensagem = Read-Host "`nDigite a mensagem do commit (Enter para padrão)"
if (-not $mensagem) { $mensagem = "Atualização automática + backup" }

git commit -m "$mensagem"


# Push
Write-Host "`n☁️ Enviando alterações para o GitHub..." -ForegroundColor Cyan
git push origin principal

Write-Host "`n✅ GitHub atualizado com sucesso!" -ForegroundColor Green


# ---------------------------------------------------------------
# ▶️ EXECUTAR STREAMLIT
# ---------------------------------------------------------------
$streamlitApp = Join-Path $projeto "app.py"

if (Test-Path $streamlitApp) {
    Write-Host "`n🚀 Iniciando o painel Streamlit..." -ForegroundColor Cyan
    streamlit run $streamlitApp
} else {
    Write-Host "`n⚠️ Arquivo app.py não encontrado. Streamlit não iniciado." -ForegroundColor Yellow
}
