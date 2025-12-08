# ================================================================
# 🚀 ATUALIZAR GITHUB + BACKUP AUTOMÁTICO + EXECUTAR STREAMLIT
# Projeto: Dashboard Esquadrão Minas
# ================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== 🚀 Atualizando repositório do painel Esquadrão Minas ===" -ForegroundColor Cyan

# ================================================================
# 🗂️ BACKUP AUTOMÁTICO
# ================================================================
$projeto = "C:\Vision\dashboard_esquadrao"
$backupDir = Join-Path $projeto "backups"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$data = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "backup_esquadrao_$data.zip"

Write-Host "`n🗂️ Criando backup do projeto..." -ForegroundColor Yellow

# Pastas a ignorar no backup
$excluir = @(
    "venv",
    ".git",
    "backups",
    "__pycache__",
    ".streamlit",
    "*.log"
)

# Arquivos permitidos no backup
$extensoesValidas = @(
    ".py", ".ps1", ".json", ".txt", ".html", ".css",
    ".js", ".png", ".ico", ".xlsx", ".csv", ".md"
)

$arquivos = Get-ChildItem -Path $projeto -Recurse -File | Where-Object {
    $fullName = $_.FullName.ToLower()
    $permitido = $true

    foreach ($ex in $excluir) {
        if ($fullName -like "*$ex*") { $permitido = $false; break }
    }

    $permitido -and ($extensoesValidas -contains $_.Extension.ToLower())
}

Compress-Archive -Path $arquivos.FullName -DestinationPath $backupFile -Force
Write-Host "✅ Backup criado com sucesso:`n$backupFile" -ForegroundColor Green

# ================================================================
# 🧠 ATUALIZAR GITHUB
# ================================================================
Write-Host "`n📂 Verificando status do repositório..." -ForegroundColor Cyan
git status

Write-Host "`n📄 Adicionando arquivos alterados..." -ForegroundColor Yellow

# Adicionar apenas arquivos que realmente existem
foreach ($ext in $extensoesValidas) {
    $lista = Get-ChildItem -Path $projeto -Recurse -File -Filter "*$ext" | Select-Object -ExpandProperty FullName
    if ($lista.Count -gt 0) {
        git add -f $lista
    }
}

# Commit
$mensagem = Read-Host "`nDigite a mensagem do commit (Enter para padrão)"
if (-not $mensagem) { $mensagem = "Atualização automática com backup" }

git commit -m "$mensagem"

# Push
Write-Host "`n☁️ Enviando alterações para o GitHub..." -ForegroundColor Cyan
git push origin principal

Write-Host "`n✅ Atualização concluída com sucesso!" -ForegroundColor Green
Write-Host "Repositório e backup sincronizados.`n"

# ================================================================
# ▶️ EXECUTAR STREAMLIT SE EXISTIR O ARQUIVO App_completo.py
# ================================================================
$streamlitApp = Join-Path $projeto "App_completo.py"

if (Test-Path $streamlitApp) {
    Write-Host "`n🚀 Iniciando o painel Streamlit..." -ForegroundColor Cyan
    streamlit run $streamlitApp
} else {
    Write-Host "`n⚠️ Nenhum arquivo App_completo.py encontrado. Streamlit não iniciado." -ForegroundColor Yellow
}
