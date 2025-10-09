Write-Host "🚀 Iniciando atualização do repositório do painel Esquadrão Minas..." -ForegroundColor Cyan

# 1️⃣ Garante que estamos na pasta correta
Set-Location "C:\Vision\dashboard_esquadrao"

# 2️⃣ Exibe status atual do repositório
git status

# 3️⃣ Adiciona e comita as alterações
git add .
$mensagem = Read-Host "✍️ Digite uma mensagem de commit (pressione Enter para usar padrão)"
if ([string]::IsNullOrWhiteSpace($mensagem)) {
    $mensagem = "🔄 Atualização automática do painel Esquadrão Minas"
}

git commit -m $mensagem

# 4️⃣ Envia tudo para o GitHub (branch principal)
Write-Host "`n📤 Enviando alterações para o GitHub..." -ForegroundColor Yellow
git push origin principal

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao enviar para o GitHub. Verifique a conexão ou as credenciais." -ForegroundColor Red
    exit
}

# 5️⃣ Força atualização do Streamlit Cloud (redeploy automático)
Write-Host "`n☁️ Solicitando atualização do app no Streamlit Cloud..." -ForegroundColor Yellow

try {
    $url = "https://dashboard-esquadrao-minas.streamlit.app/"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Deploy do Streamlit Cloud verificado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Streamlit respondeu com código $($response.StatusCode), mas o push foi feito." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "ℹ️ Push realizado, mas o Streamlit pode demorar até 1 minuto para atualizar automaticamente." -ForegroundColor Yellow
}

# 6️⃣ Mensagem final
Write-Host "`n🎯 Processo concluído com sucesso! Painel e repositório sincronizados." -ForegroundColor Green
