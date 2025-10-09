Write-Host "🚀 Iniciando atualização do repositório..." -ForegroundColor Cyan

# Garante que estamos na pasta correta
Set-Location "C:\Vision\dashboard_esquadrao"

# Adiciona e comita mudanças
git add .
$mensagem = Read-Host "✍️ Digite uma mensagem de commit (pressione Enter para padrão)"
if ([string]::IsNullOrWhiteSpace($mensagem)) {
    $mensagem = "🔄 Atualização automática do painel Esquadrão Minas"
}
git commit -m $mensagem

# Envia para o GitHub
git push origin principal

Write-Host "✅ Repositório atualizado com sucesso!" -ForegroundColor Green
