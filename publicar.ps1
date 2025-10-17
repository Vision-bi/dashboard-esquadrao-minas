# ==========================
# SCRIPT: publicar.ps1
# Atualiza o repositório no GitHub
# ==========================

Write-Host "🚀 Iniciando publicação no GitHub..." -ForegroundColor Cyan

# Ativar ambiente virtual (se existir)
$venvPath = "C:\Vision\dashboard_esquadrao\venv\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    Write-Host "Ativando ambiente virtual..."
    & $venvPath
} else {
    Write-Host "⚠️ Ambiente virtual não encontrado, pulando ativação."
}

# Entrar no diretório do projeto
Set-Location "C:\Vision\dashboard_esquadrao"

# Mostrar status
git status

# Adicionar todas as mudanças
git add -A

# Criar commit automático com data/hora
$mensagem = "Atualização automática em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
git commit -m $mensagem

# Puxar possíveis mudanças do GitHub e rebasear
git pull origin principal --rebase

# Enviar alterações
git push origin principal

# Mostrar status final
Write-Host "✅ Publicação concluída com sucesso!" -ForegroundColor Green
git status
