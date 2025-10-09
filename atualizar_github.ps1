Write-Host ""
Write-Host "=== Atualizando repositório do painel Esquadrao Minas ===" -ForegroundColor Cyan
Write-Host ""

# 1️⃣ Garante que estamos na pasta correta
Set-Location "C:\Vision\dashboard_esquadrao"

# 2️⃣ Verifica se há alterações antes de continuar
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "Nenhuma alteração detectada. O repositório já está atualizado." -ForegroundColor Green
    exit
}

# 3️⃣ Exibe status atual
Write-Host "Verificando status do repositório..." -ForegroundColor Cyan
git status

# 4️⃣ Força inclusão de planilhas Excel
Write-Host "Adicionando planilhas Excel..." -ForegroundColor Yellow
git add -f "*.xlsx"

# 5️⃣ Adiciona demais alterações
git add .

# 6️⃣ Solicita mensagem de commit
$mensagem = Read-Host "Digite uma mensagem de commit (ou pressione Enter para padrão)"
if ([string]::IsNullOrWhiteSpace($mensagem)) {
    $mensagem = "Atualização automática do painel Esquadrao Minas (planilhas + código)"
}

git commit -m "$mensagem"

# 7️⃣ Envia alterações para o GitHub
Write-Host "Enviando alterações para o GitHub..." -ForegroundColor Yellow
git push origin principal

if ($LASTEXITCODE -eq 0) {
    Write-Host "Alterações enviadas com sucesso para a branch principal!" -ForegroundColor Green
} else {
    Write-Host "Erro ao enviar para o GitHub. Verifique a conexão ou as credenciais." -ForegroundColor Red
    exit
}

# 8️⃣ Atualização no Streamlit Cloud
Write-Host "Solicitando atualização do app no Streamlit Cloud..." -ForegroundColor Yellow
try {
    $url = "https://dashboard-esquadrao-minas.streamlit.app/"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Deploy do Streamlit Cloud verificado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Streamlit respondeu com código $($response.StatusCode), mas o push foi feito." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Push realizado. O Streamlit pode demorar até 1 minuto para atualizar automaticamente." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Processo concluído com sucesso! Painel e repositório sincronizados." -ForegroundColor Green
Write-Host ""
