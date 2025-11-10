# CONFIGURACIÓN
$token = $env:GIT_TKN_BACKUP
$org = "perustn"
# $user = "stn-jescriba"

$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/vnd.github+json"
}

# FECHA Y RUTAS
$fecha = Get-Date -Format "yyyy-MM-dd"
$baseDir = "C:\backup_repos" # Carpeta base para todos los respaldos
$backupDir = "$baseDir\mirror" # Usaremos una única carpeta "mirror" para todos los repos
$reposFile = "$baseDir\repos.txt"
$zipPath = "$baseDir\repos_backup_$fecha.zip"

# VERIFICAR Y CREAR DIRECTORIOS SI NO EXISTEN
if (-not (Test-Path -Path $baseDir)) {
    Write-Host "Creando directorio base: $baseDir"
    New-Item -ItemType Directory -Path $baseDir | Out-Null
}

# OBTENER LISTA DE REPOSITORIOS DESDE GITHUB
$repos = @()
$page = 1
do {
    # Write-Host "Obteniendo repositorios del usuario '$user' (Página $page)..."
    # $url = "https://api.github.com/user/repos?type=owner&per_page=100&page=$page"
    Write-Host "Obteniendo repositorios de la organización '$org' (Página $page)..."
    $url = "https://api.github.com/orgs/$org/repos?per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    $repos += $response
    $page++
} while ($response.Count -gt 0)

# GUARDAR URLs clone_url EN repos.txt
$sshUrls = $repos | ForEach-Object { $_.clone_url }
$sshUrls | Set-Content $reposFile
Write-Host "Se encontraron $($repos.Count) repositorios. La lista se ha guardado en $reposFile."

# CLONAR CADA REPOSITORIO
$totalRepos = $sshUrls.Count
$i = 0
foreach ($repo in $sshUrls) {
    $i++
    $repoName = $repo.Split('/')[-1]
    $repoName = $repoName.Replace(".git", "")
    $destPath = Join-Path -Path $backupDir -ChildPath "$repoName.git"

    if (Test-Path $destPath) {
        Write-Host "($i/$totalRepos) Actualizando $repoName..."
        Set-Location $destPath
        git remote update --prune
    }
    else {
        Write-Host "($i/$totalRepos) Clonando $repoName por primera vez..."
        $authUrl = $repo.Replace("https://", "https://$token@")
        git clone --mirror $authUrl $destPath
    }

}

# COMPRIMIR TODOS LOS REPOSITORIOS
Compress-Archive -Path "$backupDir\*" -DestinationPath $zipPath

Write-Host "Backup completado: $zipPath"