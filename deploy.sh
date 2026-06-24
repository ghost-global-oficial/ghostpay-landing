#!/bin/bash

# Ghost Pay - Deploy Automatizado
# Uso: ./deploy.sh [opcao]
# Opcoes: github (padrao), netlify, vercel

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     GHOST PAY - DEPLOY AUTOMATIZADO    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}✗ Git não encontrado. Instale git primeiro.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Git encontrado${NC}"
}

check_gh() {
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠ GitHub CLI (gh) não encontrado.${NC}"
        echo -e "${CYAN}Instalando GitHub CLI...${NC}"
        
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            winget install GitHub.cli
        elif command -v brew &> /dev/null; then
            brew install gh
        elif command -v apt &> /dev/null; then
            (type -p wget >/dev/null || sudo apt-get install wget -y) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
        else
            echo -e "${RED}✗ Não foi possível instalar GitHub CLI automaticamente.${NC}"
            echo -e "${CYAN}Instale manualmente: https://cli.github.com/${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✓ GitHub CLI encontrado${NC}"
}

check_node() {
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}⚠ Node não encontrado (opcional para servidor local)${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Node.js encontrado${NC}"
    return 0
}

deploy_github() {
    echo -e "${CYAN}▸ Configurando deploy via GitHub Pages...${NC}"
    echo ""
    
    check_git
    check_gh
    
    cd "$(dirname "$0")"
    
    if [ ! -d ".git" ]; then
        echo -e "${CYAN}▸ Inicializando repositório Git...${NC}"
        git init
        git checkout -b main
    fi
    
    echo -e "${CYAN}▸ Configurando git...${NC}"
    git config user.email "deploy@ghostpay.com" 2>/dev/null || true
    git config user.name "Ghost Pay Deploy" 2>/dev/null || true
    
    echo -e "${CYAN}▸ Verificando login do GitHub...${NC}"
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠ Precisa fazer login no GitHub${NC}"
        gh auth login --web -p https
    fi
    
    echo -e "${CYAN}▸ Adicionando arquivos...${NC}"
    git add -A
    git commit -m "Deploy: landing page Ghost Pay" 2>/dev/null || echo "Nada para commitar"
    
    echo -e "${CYAN}▸ Criando repositório no GitHub...${NC}"
    REPO_NAME="ghostpay-landing"
    
    if gh repo view "$REPO_NAME" &> /dev/null; then
        echo -e "${YELLOW}⚠ Repositório já existe. Usando existente.${NC}"
    else
        gh repo create "$REPO_NAME" --public --source=. --remote=origin --push 2>/dev/null || true
    fi
    
    echo -e "${CYAN}▸ Enviando código...${NC}"
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$(gh api user -q .login)/$REPO_NAME.git" 2>/dev/null || true
    git push -u origin main 2>/dev/null || git push --force origin main
    
    echo -e "${CYAN}▸ Ativando GitHub Pages...${NC}"
    gh api repos/{owner}/{repo}/pages -X POST -f build_type=legacy -f source.branch=main -f source.path=/ 2>/dev/null || \
    gh api repos/{owner}/{repo}/pages -X PUT -f build_type=legacy -f source.branch=main -f source.path=/ 2>/dev/null || \
    echo -e "${YELLOW}⚠ Ative GitHub Pages manualmente no repositório${NC}"
    
    USERNAME=$(gh api user -q .login 2>/dev/null)
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        DEPLOY CONCLUÍDO! ✓             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Seu site está em:${NC}"
    echo -e "${GREEN}→ https://${USERNAME}.github.io/${REPO_NAME}/${NC}"
    echo ""
    echo -e "${CYAN}Próximos passos:${NC}"
    echo -e "1. Acesse https://github.com/${USERNAME}/${REPO_NAME}/settings/pages"
    echo -e "2. Verifique se GitHub Pages está ativo"
    echo -e "3. Aguarde 2-3 minutos para propagar"
    echo ""
}

deploy_netlify() {
    echo -e "${CYAN}▸ Configurando deploy via Netlify...${NC}"
    echo ""
    
    check_node
    
    if ! command -v netlify &> /dev/null; then
        echo -e "${CYAN}▸ Instalando Netlify CLI...${NC}"
        npm install -g netlify-cli
    fi
    
    cd "$(dirname "$0")"
    
    echo -e "${CYAN}▸ Fazendo login no Netlify...${NC}"
    netlify login
    
    echo -e "${CYAN}▸ Criando site...${NC}"
    netlify init
    
    echo -e "${CYAN}▸ Fazendo deploy...${NC}"
    netlify deploy --prod
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        DEPLOY CONCLUÍDO! ✓             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

deploy_vercel() {
    echo -e "${CYAN}▸ Configurando deploy via Vercel...${NC}"
    echo ""
    
    if ! command -v vercel &> /dev/null; then
        echo -e "${CYAN}▸ Instalando Vercel CLI...${NC}"
        npm install -g vercel
    fi
    
    cd "$(dirname "$0")"
    
    echo -e "${CYAN}▸ Fazendo deploy...${NC}"
    vercel --prod
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        DEPLOY CONCLUÍDO! ✓             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

deploy_local() {
    echo -e "${CYAN}▸ Iniciando servidor local...${NC}"
    echo ""
    
    cd "$(dirname "$0")"
    
    if check_node; then
        echo -e "${GREEN}✓ Acesse: http://localhost:3000${NC}"
        npx serve . -l 3000
    else
        echo -e "${YELLOW}⚠ Node não encontrado. Use um servidor estático:${NC}"
        echo -e "  - Python: python -m http.server 3000"
        echo -e "  - PHP: php -S localhost:3000"
        echo -e "  - Live Server (VS Code)"
    fi
}

case "${1:-github}" in
    github|gh)
        deploy_github
        ;;
    netlify|nl)
        deploy_netlify
        ;;
    vercel|vc)
        deploy_vercel
        ;;
    local|dev)
        deploy_local
        ;;
    *)
        echo -e "${RED}Opção inválida: $1${NC}"
        echo ""
        echo "Uso: $0 [opcao]"
        echo ""
        echo "Opções:"
        echo "  github   - Deploy via GitHub Pages (padrão)"
        echo "  netlify  - Deploy via Netlify"
        echo "  vercel   - Deploy via Vercel"
        echo "  local    - Servidor local para teste"
        exit 1
        ;;
esac
