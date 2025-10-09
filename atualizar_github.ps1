# =============================================
# 🚀 Atualizador automático do GitHub - Esquadrão Minas
# =============================================

cd "C:\Vision\dashboard_esquadrao"

# Evita subir venv, caches e temporários
$env:GIT_PAGER = ''
Write-Host "🔍 Limpando arquivos ignorados e preparando commit..." -ForegroundColor Cyan
git rm -r --cached venv 2>$null
git rm --cached desktop.ini 2>$null

# Adiciona alterações reais
git add .

# Cria commit automático com data e hora
$hora = Get-Date -Format "dd/MM/yyyy HH:mm"
git commit -m "Atualização automática em $hora" 2>$null

# Envia para o repositório remoto
Write-Host "🚀 Enviando atualizações para o GitHub..." -ForegroundColor Green
git push origin principal

Write-Host "`n✅ Atualização concluída com sucesso!" -ForegroundColor Yellow
Pause
