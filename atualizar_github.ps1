# ================================================================
# CAMINHO: C:\Vision\dashboard_esquadrao\
# ARQUIVO: atualizar_github.ps1
#
# DESCRIÇÃO:
# Atualiza o repositório GitHub do Dashboard Esquadrão Minas,
# criando backup automático e executando Streamlit se aplicável.
#
# RESPONSABILIDADES:
# - Criar backup zipado do projeto
# - Versionar corretamente arquivos alterados
# - Forçar commit de planilhas Excel
# - Enviar alterações ao GitHub
# - Executar Streamlit se App_completo.py existir
# ================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== 🚀 Atualizando repositório do painel Esquadrão Minas ===" -ForegroundColor Cyan

# ================================================================
# 🗂️ BACKUP AUTOMÁTICO
# ================================================================
$projeto   = "C:\Vision\dashboard_esquadrao"
$backupDir = Join-Path $projeto "backups"

if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$data       = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "backup_esquadrao_$data.zip"

Write-Host "`n🗂️ Criando backup do projeto..." -ForegroundColor Yellow

$excluir = @(
    "venv",
    ".git",
    "backups",
    "__pycache__",
    ".streamlit",
    "*.log"
)

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

# 🔒 Estratégia segura (SEM estouro de path)
git add -u
git add *.xlsx

# Commit
$mensagem = Read-Host "`nDigite a mensagem do commit (Enter para padrão)"
if (-not $mensagem) {
    $mensagem = "Atualização automática com backup"
}

git commit -m "$mensagem"

# Push
Write-Host "`n☁️ Enviando alterações para o GitHub..." -ForegroundColor Cyan
git push origin principal

Write-Host "`n✅ Atualização concluída com sucesso!" -ForegroundColor Green
Write-Host "Repositório e backup sincronizados.`n"

# ================================================================
# ▶️ EXECUTAR STREAMLIT
# ================================================================
$streamlitApp = Join-Path $projeto "App_completo.py"

if (Test-Path $streamlitApp) {
    Write-Host "`n🚀 Iniciando o painel Streamlit..." -ForegroundColor Cyan
    streamlit run $streamlitApp
} else {
    Write-Host "`n⚠️ Nenhum arquivo App_completo.py encontrado. Streamlit não iniciado." -ForegroundColor Yellow
}
