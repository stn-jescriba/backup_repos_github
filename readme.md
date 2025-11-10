# Cómo Restaurar un Repositorio Git desde el Backup

Este documento explica cómo restaurar un repositorio de Git desde un archivo de respaldo (`.zip`) generado por el script `get_repo_git_hub.ps1`.

El proceso de backup utiliza `git clone --mirror`, creando una copia exacta del repositorio remoto. Esta copia, conocida como repositorio "bare" (desnudo), contiene toda la historia del repositorio, incluyendo todas las ramas y etiquetas (tags), pero sin un directorio de trabajo con los archivos visibles.

---

## Ejecutar script

Ejecute estos comandos desde **PowerShell** con permisos de administrador.

1.  **Crear variable de entorno:**

```
[System.Environment]::SetEnvironmentVariable("GIT_TKN_BACKUP", "token github", "Machine")
```


2.  **Crear backup:**

```powershell
powershell -ExecutionPolicy Bypass -File .\get_repo_git_hub.ps1
```

## Escenarios de Restauración

Existen dos escenarios comunes para restaurar un repositorio:

1.  **Restaurar en un nuevo repositorio remoto (Ej. en GitHub):** Útil si el repositorio original fue eliminado o corrompido. Se "empuja" el backup a un nuevo repositorio vacío en GitHub.
2.  **Restaurar a una copia local:** Útil si solo necesitas recuperar los archivos y el historial en tu máquina local para trabajar con ellos.

---

## Pasos para la Restauración

### Paso 1: Descomprimir el Backup

1.  Localiza el archivo de backup que deseas restaurar, por ejemplo: `C:\backup_repos\repos_backup_2025-11-10.zip`.
2.  Descomprímelo en una carpeta. Dentro encontrarás una carpeta `mirror` que contiene todos los repositorios respaldados, cada uno en una carpeta con el sufijo `.git`.

    ```
    C:\TEMP_RESTORE\
    └── mirror\
        ├── mi-repo-1.git\
        ├── mi-repo-2.git\
        └── otro-repo.git\
    ```

### Paso 2: Restaurar en un Nuevo Repositorio Remoto (GitHub)

Este es el método recomendado para una recuperación completa en caso de desastre.

1.  **Crea un nuevo repositorio vacío en GitHub.** No añadas `README`, `.gitignore` ni licencia. Solo crea el repositorio.
2.  Copia la URL del nuevo repositorio. Por ejemplo: `https://github.com/tu-usuario/mi-repo-restaurado.git`.
3.  Abre una terminal o PowerShell y navega hasta la carpeta del repositorio que quieres restaurar.

    ```powershell
    # Navega a la carpeta del repositorio "bare" que descomprimiste
    cd C:\TEMP_RESTORE\mirror\mi-repo-1.git
    ```

4.  Ejecuta el comando `git push --mirror` para subir todo el historial (ramas y etiquetas) al nuevo repositorio.

    ```powershell
    # Reemplaza la URL con la de tu nuevo repositorio en GitHub
    git push --mirror https://github.com/tu-usuario/mi-repo-restaurado.git
    ```

¡Listo! El nuevo repositorio en GitHub ahora contiene una copia exacta del repositorio respaldado.

### Paso 3: Restaurar a una Copia de Trabajo Local

Si solo necesitas una copia funcional en tu máquina para ver los archivos o continuar trabajando.

1.  Abre una terminal o PowerShell y navega a la ubicación donde quieres clonar el repositorio.
2.  Usa el comando `git clone` apuntando a la carpeta `.git` del backup. Git creará una copia de trabajo normal a partir del repositorio "bare".

    ```powershell
    # Clona el repositorio desde la carpeta del backup a una nueva carpeta "mi-repo-local"
    # Asegúrate de usar la ruta a la carpeta .git que descomprimiste
    git clone C:\TEMP_RESTORE\mirror\mi-repo-1.git mi-repo-local
    ```

3.  Ahora tienes una carpeta `mi-repo-local` con todos los archivos del proyecto y su historial, lista para usar.

    ```powershell
    cd mi-repo-local
    git log
    # Verás todo el historial de commits
    ```
