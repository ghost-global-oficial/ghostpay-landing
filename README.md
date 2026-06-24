# Ghost Pay - Landing Page

Landing page oficial do Ghost Pay - Pagamentos Cripto Anónimos.

## Deploy Rápido (1 comando)

### Windows
```cmd
deploy.bat
```

### Linux/Mac
```bash
chmod +x deploy.sh
./deploy.sh
```

Isso vai:
1. Criar o repositório no GitHub
2. Ativar GitHub Pages
3. Publicar o site automaticamente

### Outras opções de deploy
```bash
# Netlify
deploy.bat netlify

# Vercel
deploy.bat vercel

# Servidor local (teste)
deploy.bat local
```

## Deploy Manual

### GitHub Pages
1. Crie um repositório no GitHub chamado `ghostpay-landing`
2. Faça push dos arquivos
3. Ative GitHub Pages em Settings → Pages
4. Selecione branch `main` e pasta `/ (root)`

### Netlify
1. Acesse [netlify.com](https://netlify.com)
2. Arraste a pasta `landing-page` para o deploy
3. Pronto!

### Vercel
1. Acesse [vercel.com](https://vercel.com)
2. Importe o repositório
3. Deploy automático

## Desenvolvimento

```bash
npm run dev
```

Acesse: http://localhost:3000

## Estrutura

```
landing-page/
├── index.html      # Página principal
├── styles.css      # Estilos
├── main.js         # JavaScript
├── netlify.toml    # Config Netlify
├── vercel.json     # Config Vercel
├── .htaccess       # Config Apache
└── _redirects      # Redirects Netlify
```

## Segurança

- Headers de segurança configurados
- CSP (Content Security Policy) habilitado
- Forçar HTTPS
- Cache otimizado

## Licença

MIT
