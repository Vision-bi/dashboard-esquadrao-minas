# ==========================
# SCRIPT: atualizar_github.ps1
# Atualiza automaticamente o repositório no GitHub,
# incluindo todas as planilhas (.xlsx) e arquivos principais.
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

# Buscar automaticamente todos os arquivos .xlsx no diretorio
$planilhas = Get-ChildItem -Path $projeto -Filter *.xlsx -File | Where-Object {
    $_.Name -notmatch '^~' -and $_.Name -notmatch '^\.'
}

# Arquivos fixos adicionais
$arquivosFixos = @(
    "campanha_flag.json",
    "App_completo.py"
)

# Combinar todos os arquivos alvo
$arquivos = @()
$arquivos += $planilhas.FullName
foreach ($fixo in $arquivosFixos) {
    if (Test-Path $fixo) {
        $arquivos += (Resolve-Path $fixo)
    }
}

# Mostrar lista de arquivos que serao adicionados
Write-Host "`nArquivos que serao atualizados:" -ForegroundColor Yellow
$arquivos | ForEach-Object { Write-Host " - $($_)" }

# Adicionar os arquivos ao Git
foreach ($arq in $arquivos) {
    Write-Host "Adicionando: $arq"
    git add --force "$arq"
}

# Adicionar todas as outras mudancas tambem
git add -A

# Verificar se ha alteracoes pendentes
$alteracoes = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($alteracoes)) {

    # Commit automatico com data/hora
    $mensagem = "Atualizacao automatica em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
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
