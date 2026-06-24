@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Ghost Pay - Deploy Automatizado (Windows)
:: Uso: deploy.bat [opcao]
:: Opcoes: github (padrao), netlify, vercel, local

title Ghost Pay - Deploy

echo.
echo ╔════════════════════════════════════════╗
echo ║     GHOST PAY - DEPLOY AUTOMATIZADO    ║
echo ╚════════════════════════════════════════╝
echo.

set "OPCAO=%1"
if "%OPCAO%"=="" set "OPCAO=github"

if "%OPCAO%"=="github" goto :deploy_github
if "%OPCAO%"=="gh" goto :deploy_github
if "%OPCAO%"=="netlify" goto :deploy_netlify
if "%OPCAO%"=="nl" goto :deploy_netlify
if "%OPCAO%"=="vercel" goto :deploy_vercel
if "%OPCAO%"=="vc" goto :deploy_vercel
if "%OPCAO%"=="local" goto :deploy_local
if "%OPCAO%"=="dev" goto :deploy_local

echo Opcao invalida: %OPCAO%
echo.
echo Uso: deploy.bat [opcao]
echo.
echo Opcoes:
echo   github   - Deploy via GitHub Pages (padrao)
echo   netlify  - Deploy via Netlify
echo   vercel   - Deploy via Vercel
echo   local    - Servidor local para teste
exit /b 1

:check_git
where git >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Git nao encontrado. Instale git primeiro.
    echo https://git-scm.com/download/win
    exit /b 1
)
echo [OK] Git encontrado
goto :eof

:check_gh
where gh >nul 2>nul
if errorlevel 1 (
    echo [AVISO] GitHub CLI nao encontrado.
    echo Instalando...
    winget install GitHub.cli
    if errorlevel 1 (
        echo [ERRO] Nao foi possivel instalar GitHub CLI.
        echo Instale manualmente: https://cli.github.com/
        exit /b 1
    )
)
echo [OK] GitHub CLI encontrado
goto :eof

:deploy_github
echo [%TIME%] Configurando deploy via GitHub Pages...
echo.

call :check_git
call :check_gh

cd /d "%~dp0"

if not exist ".git" (
    echo [%TIME%] Inicializando repositorio Git...
    git init
    git checkout -b main
)

echo [%TIME%] Configurando git...
git config user.email "deploy@ghostpay.com" 2>nul
git config user.name "Ghost Pay Deploy" 2>nul

echo [%TIME%] Verificando login do GitHub...
gh auth status >nul 2>nul
if errorlevel 1 (
    echo [AVISO] Precisa fazer login no GitHub.
    gh auth login --web -p https
)

echo [%TIME%] Adicionando arquivos...
git add -A
git commit -m "Deploy: landing page Ghost Pay" 2>nul || echo Nada para commitar

echo [%TIME%] Criando repositorio no GitHub...
set "REPO_NAME=ghostpay-landing"

gh repo view %REPO_NAME% >nul 2>nul
if errorlevel 1 (
    gh repo create %REPO_NAME% --public --source=. --remote=origin --push
) else (
    echo [AVISO] Repositorio ja existe. Usando existente.
)

echo [%TIME%] Enviando codigo...
git remote remove origin 2>nul
for /f "tokens=*" %%i in ('gh api user -q .login 2^>nul') do set "USERNAME=%%i"
git remote add origin "https://github.com/%USERNAME%/%REPO_NAME%.git" 2>nul
git push -u origin main 2>nul || git push --force origin main

echo [%TIME%] Ativando GitHub Pages...
gh api repos/{owner}/{repo}/pages -X POST -f build_type=legacy -f source.branch=main -f source.path=/ 2>nul || echo [AVISO] Ative GitHub Pages manualmente

echo.
echo ╔════════════════════════════════════════╗
echo ║        DEPLOY CONCLUIDO! ✓             ║
echo ╚════════════════════════════════════════╝
echo.
echo Seu site esta em:
echo → https://%USERNAME%.github.io/%REPO_NAME%/
echo.
echo Proximos passos:
echo 1. Acesse https://github.com/%USERNAME%/%REPO_NAME%/settings/pages
echo 2. Verifique se GitHub Pages esta ativo
echo 3. Aguarde 2-3 minutos para propagar
echo.
goto :eof

:deploy_netlify
echo [%TIME%] Configurando deploy via Netlify...
echo.

where netlify >nul 2>nul
if errorlevel 1 (
    echo [%TIME%] Instalando Netlify CLI...
    npm install -g netlify-cli
)

cd /d "%~dp0"

echo [%TIME%] Fazendo login no Netlify...
netlify login

echo [%TIME%] Criando site...
netlify init

echo [%TIME%] Fazendo deploy...
netlify deploy --prod

echo.
echo ╔════════════════════════════════════════╗
echo ║        DEPLOY CONCLUIDO! ✓             ║
echo ╚════════════════════════════════════════╝
echo.
goto :eof

:deploy_vercel
echo [%TIME%] Configurando deploy via Vercel...
echo.

where vercel >nul 2>nul
if errorlevel 1 (
    echo [%TIME%] Instalando Vercel CLI...
    npm install -g vercel
)

cd /d "%~dp0"

echo [%TIME%] Fazendo deploy...
vercel --prod

echo.
echo ╔════════════════════════════════════════╗
echo ║        DEPLOY CONCLUIDO! ✓             ║
echo ╚════════════════════════════════════════╝
echo.
goto :eof

:deploy_local
echo [%TIME%] Iniciando servidor local...
echo.

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
    echo [AVISO] Node nao encontrado.
    echo Use um servidor estatico:
    echo   - Python: python -m http.server 3000
    echo   - PHP: php -S localhost:3000
    echo   - Live Server (VS Code)
    goto :eof
)

echo [OK] Acesse: http://localhost:3000
npx serve . -l 3000
goto :eof
