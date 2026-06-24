# Ghost Pay - Landing Page + Payment Pages

Landing page e páginas de pagamento hosted do Ghost Pay.

## Estrutura

```
landing-page/
├── index.html              # Landing page principal
├── styles.css              # Estilos
├── main.js                 # JavaScript
├── pages/
│   ├── payment.html        # Checkout de pagamento (hosted)
│   └── scan.html           # Scanner QR code (hosted)
├── sdk/
│   └── ghostpay-sdk.js     # Bundle UMD do SDK
├── components/
│   └── ghost-qrcode.js     # Componente QR code
├── vercel.json             # Config Vercel (rotas: /payment, /scan)
├── netlify.toml            # Config Netlify
├── .htaccess               # Config Apache
└── _redirects              # Redirects Netlify
```

## Páginas de Pagamento

### Checkout (`/payment`)

URL:
```
https://ghostpay-landing.vercel.app/payment?receiver=Loja&amount=25&currency=USD&chain=ethereum&address=0x...&sig=abc123
```

Parâmetros suportados:
| Parâmetro | Obrigatório | Descrição |
|-----------|-------------|-----------|
| `receiver` | Sim | Nome do recebedor |
| `amount` | Sim | Valor do pagamento |
| `currency` | Sim | Moeda (USD, EUR, etc.) |
| `chain` | Sim | Blockchain (bitcoin, ethereum, solana, polygon, bsc) |
| `address` | Sim | Endereço da wallet do recebedor |
| `plan` | Não | ID do plano |
| `description` | Não | Descrição do pagamento |
| `sig` | Não | HMAC-SHA256 (verificação de integridade) |

### Scanner (`/scan`)

URL:
```
https://ghostpay-landing.vercel.app/scan
```

Escaneia QR codes com formato `ghostpay:payment?...` e verifica a assinatura HMAC.

## Deploy

### Vercel (Recomendado)

1. Conecta o repositório ao Vercel
2. Deploy automático
3. URLs: `https://ghostpay-landing.vercel.app/`

### Deploy Rápido

```bash
# Windows
deploy.bat

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```

### Outras opções

```bash
deploy.bat netlify    # Netlify
deploy.bat vercel     # Vercel
deploy.bat local      # Servidor local
```

## Integração com Ghost Wallet

A app Android Ghost Wallet escaneia QR codes e abre automaticamente a página de pagamento hosted:

```typescript
// Ao escanear QR code com ghostpay:payment?...
if (scannedData.startsWith('ghostpay:payment?')) {
  const queryString = scannedData.replace('ghostpay:payment?', '');
  const paymentUrl = `https://ghostpay-landing.vercel.app/payment?${queryString}`;
  Linking.openURL(paymentUrl);
}
```

## Segurança

- Headers de segurança configurados
- CSP (Content Security Policy) habilitado
- Forçar HTTPS
- Cache otimizado
- Páginas hosted em domínio controlado (impossível manipular localmente)

## Licença

MIT
