# ==========================
# SCRIPT: publicar.ps1
# Atualiza o repositório no GitHub — força atualização da planilha e demais arquivos
# ==========================

Write-Host "`n=== Publicando alterações no GitHub ===`n" -ForegroundColor Cyan

# Caminho do projeto
$projeto = "C:\Vision\dashboard_esquadrao"
Set-Location $projeto

# Ativar ambiente virtual (se existir)
$venvPath = "$projeto\venv\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    Write-Host "Ativando ambiente virtual..."
    & $venvPath
} else {
    Write-Host "⚠️ Ambiente virtual não encontrado, pulando ativação."
}

# Forçar atualização de arquivos importantes
$arquivos = @(
    "Esquadrao.xlsx",
    "Metas Esquadrao Minas.xlsx",
    "campanha_flag.json",
    "App_completo.py"
)

foreach ($arq in $arquivos) {
    if (Test-Path $arq) {
        Write-Host "🔁 Forçando atualização de: $arq"
        git add --force "$arq"
    } else {
        Write-Host "⚠️ Arquivo não encontrado: $arq"
    }
}

# Adicionar todas as outras mudanças também
git add -A

# Commit automático com data/hora
$mensagem = "Atualização forçada em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
git commit -m $mensagem

# Sincronizar com o GitHub
Write-Host "⬇️  Puxando alterações do remoto..."
git pull origin principal --rebase

Write-Host "⬆️  Enviando alterações..."
git push origin principal

Write-Host "`n✅ Publicação concluída com sucesso!" -ForegroundColor Green
git status
