# ================================================================
# 🚀 ATUALIZAR GITHUB + BACKUP AUTOMÁTICO
# Projeto: Dashboard Esquadrão Minas
# ================================================================

# Garante que o console use UTF-8 (corrige acentuação)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== 🚀 Atualizando repositório do painel Esquadrão Minas ===" -ForegroundColor Cyan

# ================================================================
# 🧩 BACKUP AUTOMÁTICO
# ================================================================
$projeto = "C:\Vision\dashboard_esquadrao"
$backupDir = Join-Path $projeto "backups"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$data = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "backup_esquadrao_$data.zip"

Write-Host "`n🗂️ Criando backup do projeto..." -ForegroundColor Yellow

$excluir = @("venv", ".git", ".streamlit", "backups", "__pycache__", "*.log")

$arquivos = Get-ChildItem -Path $projeto -Recurse -File |
    Where-Object {
        $ok = $true
        foreach ($ex in $excluir) {
            if ($_.FullName -like "*\$ex*") { $ok = $false; break }
        }
        $ok
    }

Compress-Archive -Path $arquivos.FullName -DestinationPath $backupFile -Force
Write-Host "✅ Backup criado com sucesso em:`n$backupFile" -ForegroundColor Green

# ================================================================
# 🧠 GIT - ATUALIZAÇÃO DO REPOSITÓRIO
# ================================================================

# Ativa o ambiente virtual se existir
$venv = "$projeto\venv\Scripts\Activate.ps1"
if (Test-Path $venv) {
    Write-Host "`n🔧 Ativando ambiente virtual..." -ForegroundColor Yellow
    & $venv
}

Write-Host "`n📂 Verificando status do repositório..." -ForegroundColor Cyan
git status

# Força adicionar arquivos importantes, mesmo se ignorados
Write-Host "`n📄 Adicionando planilhas e scripts atualizados..." -ForegroundColor Yellow
git add -f *.xlsx, *.py, *.json, *.ps1, *.png, *.ico, *.txt

# Commit
$mensagem = Read-Host "`nDigite uma mensagem de commit (ou pressione Enter para padrão)"
if (-not $mensagem) { $mensagem = "Atualização automática com backup" }

git commit -m "$mensagem"

# Push para o GitHub
Write-Host "`n☁️ Enviando alterações para o GitHub..." -ForegroundColor Cyan
git push origin principal

Write-Host "`n✅ Atualização concluída com sucesso!" -ForegroundColor Green
Write-Host "Repositório e backup sincronizados.`n"
