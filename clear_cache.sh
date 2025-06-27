#!/bin/bash

echo "🔄 Executando limpeza de cache do título..."
echo ""

# Fazer a requisição
response=$(curl -s -X POST https://suporte.kirvano.com/admin/clear_title_cache \
  -H "Content-Type: application/json" \
  -d '{"secret_token":"40c03b735772d8d74efb20a"}')

# Verificar se foi sucesso
if echo "$response" | grep -q "final_values"; then
    echo "✅ Limpeza executada com sucesso!"
    echo ""
    echo "📋 Resultado:"
    echo "$response" | python3 -m json.tool
else
    echo "❌ Erro ao executar limpeza:"
    echo "$response"
fi

echo ""
echo "🧹 Próximos passos:"
echo "1. Limpe o cache do navegador (Cmd+Shift+R)"
echo "2. Delete os arquivos temporários:"
echo "   - app/controllers/admin/cache_clear_controller.rb"
echo "   - Remova a rota de config/routes.rb"
