# ========================================================
# 🧹 CORRIGIR_GIT.PS1 — Limpa lixo interno e repara repositório Git
# ========================================================

Write-Host "🔧 Iniciando reparo do repositório Git..." -ForegroundColor Cyan
Set-Location "C:\Vision\dashboard_esquadrao"

# Remove arquivos desktop.ini espalhados dentro do .git
Get-ChildItem -Path ".git" -Recurse -Include "desktop.ini" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Verifica integridade e limpa histórico
git fsck --full
git reflog expire --expire=now --all
git gc --prune=now --aggressive

Write-Host "✅ Repositório Git reparado com sucesso!" -ForegroundColor Green
Write-Host "ℹ️  Agora o Git está limpo e pronto para uso."
