# ================================================================
# 🧩 BACKUP DO PROJETO DASHBOARD ESQUADRÃO
# ================================================================
# Cria um ZIP de backup com data e hora, ignorando pastas pesadas
# ================================================================

# Diretório base do projeto
$projeto = "C:\Vision\dashboard_esquadrao"

# Pasta onde os backups serão armazenados
$backupDir = Join-Path $projeto "backups"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

# Nome do arquivo ZIP com data e hora
$data = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "backup_esquadrao_$data.zip"

Write-Host "=== 🗂️ Criando backup do projeto Esquadrão Minas ===" -ForegroundColor Cyan
Write-Host "Destino: $backupFile" -ForegroundColor Yellow

# Arquivos e pastas a ignorar
$excluir = @(
    "venv",
    ".git",
    ".streamlit",
    "backups",
    "__pycache__",
    "*.log"
)

# Monta a lista de arquivos válidos
$arquivos = Get-ChildItem -Path $projeto -Recurse -File |
    Where-Object {
        $ok = $true
        foreach ($ex in $excluir) {
            if ($_.FullName -like "*\$ex*") { $ok = $false; break }
        }
        $ok
    }

# Cria o ZIP
Compress-Archive -Path $arquivos.FullName -DestinationPath $backupFile -Force

Write-Host "✅ Backup criado com sucesso!" -ForegroundColor Green
Write-Host "Arquivo salvo em: $backupFile"
