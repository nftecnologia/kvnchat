# MCP DigitalOcean Server

Este é um servidor MCP (Model Context Protocol) para interagir com a API da DigitalOcean.

## ⚠️ SEGURANÇA IMPORTANTE

1. **NUNCA** compartilhe sua API key publicamente
2. **SEMPRE** revogue chaves comprometidas imediatamente
3. **NUNCA** faça commit do arquivo `.env` no git

## 🚀 Configuração

### 1. Obter API Token da DigitalOcean

1. Acesse: https://cloud.digitalocean.com/account/api/tokens
2. Clique em "Generate New Token"
3. Dê um nome ao token (ex: "MCP Server")
4. Selecione as permissões necessárias
5. Copie o token gerado

### 2. Configurar o Token

Edite o arquivo `.env`:
```bash
DIGITALOCEAN_API_TOKEN=seu_token_aqui
```

### 3. Configurar no Cline

O arquivo de configuração já foi criado em:
`~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

Atualize o token no arquivo de configuração:
```json
{
  "mcpServers": {
    "digitalocean": {
      "command": "node",
      "args": ["/Users/oliveira/mcp-digitalocean-server/index.js"],
      "env": {
        "DIGITALOCEAN_API_TOKEN": "seu_token_aqui"
      }
    }
  }
}
```

### 4. Reiniciar o Cline

Após configurar, reinicie o Cline (recarregue a janela do VSCode).

## 📋 Ferramentas Disponíveis

- `list_droplets`: Lista todos os droplets
- `get_console_url`: Obtém URL do console de um droplet
- `restart_droplet`: Reinicia um droplet
- `execute_command`: Placeholder para execução de comandos (requer SSH)

## 🔧 Para executar comandos no servidor

Como a API da DigitalOcean não permite execução direta de comandos, você tem estas opções:

1. **Usar o Console Web**: Use `get_console_url` para obter o link
2. **Configurar SSH**: Configure acesso SSH ao servidor
3. **Criar uma rota temporária**: No seu app Rails para executar o script

## 📝 Exemplo de uso para limpar cache do Chatwoot

1. Liste os droplets para encontrar o ID
2. Use o console web ou SSH para executar:
   ```bash
   cd /caminho/do/app
   rails runner db/scripts/final_title_fix.rb
