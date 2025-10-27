# ==========================
# SCRIPT: atualizar_github.ps1
# Atualiza o repositorio no GitHub — forca atualizacao das planilhas e arquivos principais
# ==========================

Write-Host "`n=== Publicando alteracoes no GitHub ===`n" -ForegroundColor Cyan

# Caminho do projeto
$projeto = "C:\Vision\dashboard_esquadrao"
Set-Location $projeto

# Ativar ambiente virtual (se existir)
$venvPath = "$projeto\venv\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    Write-Host "Ativando ambiente virtual..."
    & $venvPath
} else {
    Write-Host "Ambiente virtual nao encontrado, pulando ativacao."
}

# Detectar automaticamente a branch
$branchAtual = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branchAtual) {
    $branchAtual = "principal"
}
Write-Host "Branch atual: $branchAtual"

# Forcar atualizacao de arquivos importantes
$arquivos = @(
    "Esquadrao.xlsx",
    "Metas Esquadrao Minas.xlsx",
    "campanha_flag.json",
    "App_completo.py"
)

foreach ($arq in $arquivos) {
    if (Test-Path $arq) {
        Write-Host "Adicionando arquivo: $arq"
        git add --force "$arq"
    } else {
        Write-Host "Aviso: arquivo nao encontrado -> $arq"
    }
}

# Adicionar todas as outras mudancas tambem
git add -A

# Verificar se ha alteracoes pendentes
$alteracoes = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($alteracoes)) {

    # Commit automatico com data/hora
    $mensagem = "Atualizacao forcada em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
    git commit -m $mensagem

    # Sincronizar com o GitHub
    Write-Host "Puxando alteracoes do remoto..."
    git pull origin $branchAtual --rebase

    Write-Host "Enviando alteracoes..."
    git push origin $branchAtual

    Write-Host "`nPublicacao concluida com sucesso!" -ForegroundColor Green
} else {
    Write-Host "`nNenhuma alteracao detectada. Nenhum commit necessario." -ForegroundColor Yellow
}

git status
