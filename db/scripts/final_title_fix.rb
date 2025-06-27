#!/usr/bin/env ruby
# Script definitivo para remover "Chatwoot" do título da aba
# Execute com: rails runner db/scripts/final_title_fix.rb

puts "🚀 SOLUÇÃO DEFINITIVA: Removendo 'Chatwoot' do título da aba"
puts "=" * 60
puts

# 1. Atualizar banco de dados
puts "1️⃣ Atualizando banco de dados:"
['INSTALLATION_NAME', 'BRAND_NAME'].each do |config_name|
  config = InstallationConfig.find_or_create_by(name: config_name)
  if config.value != 'Kirvano'
    config.update(value: 'Kirvano')
    puts "   ✅ #{config_name} atualizado para 'Kirvano'"
  else
    puts "   ✅ #{config_name} já está correto: 'Kirvano'"
  end
end
puts

# 2. Limpar TODOS os caches
puts "2️⃣ Limpando TODOS os caches:"

# Cache do GlobalConfig
GlobalConfig.clear_cache
puts "   ✅ GlobalConfig cache limpo"

# Cache específico do Redis
['INSTALLATION_NAME', 'BRAND_NAME'].each do |key|
  cache_key = "V1:GLOBAL_CONFIG:#{key}"
  $alfred.with { |conn| conn.del(cache_key) }
  puts "   ✅ Redis cache limpo: #{cache_key}"
end

# Limpar TODAS as chaves do GlobalConfig
all_keys = $alfred.with { |conn| conn.keys("*GLOBAL_CONFIG*") }
all_keys.each do |key|
  $alfred.with { |conn| conn.del(key) }
end
puts "   ✅ Todas as chaves GlobalConfig removidas (#{all_keys.size} chaves)"

# Cache do Rails
Rails.cache.clear
puts "   ✅ Rails cache limpo"

# Fragment cache
begin
  ActionController::Base.new.expire_fragment(/.*/)
  puts "   ✅ Fragment cache limpo"
rescue => e
  puts "   ⚠️  Fragment cache: #{e.message}"
end
puts

# 3. Verificar valores finais
puts "3️⃣ Verificando valores finais:"
final_installation = GlobalConfig.get_value('INSTALLATION_NAME')
final_brand = GlobalConfig.get_value('BRAND_NAME')
puts "   INSTALLATION_NAME: #{final_installation}"
puts "   BRAND_NAME: #{final_brand}"
puts

# 4. Instruções para o navegador
puts "4️⃣ INSTRUÇÕES IMPORTANTES PARA O NAVEGADOR:"
puts
puts "   🔴 PASSO 1: Limpar dados do navegador"
puts "      - Abra as ferramentas do desenvolvedor (F12)"
puts "      - Vá para a aba 'Application' (Chrome) ou 'Storage' (Firefox)"
puts "      - Clique em 'Clear site data' ou 'Clear storage'"
puts
puts "   🔴 PASSO 2: Desregistrar Service Workers"
puts "      - Na aba 'Application' > 'Service Workers'"
puts "      - Clique em 'Unregister' em todos os workers listados"
puts
puts "   🔴 PASSO 3: Hard refresh"
puts "      - Windows/Linux: Ctrl + Shift + R"
puts "      - Mac: Cmd + Shift + R"
puts "      - Ou: Ctrl/Cmd + clique no botão de recarregar"
puts
puts "   🔴 PASSO 4: Se ainda não funcionar"
puts "      - Feche TODAS as abas do navegador"
puts "      - Limpe o cache do navegador completamente"
puts "      - Abra em modo incógnito/privado primeiro para testar"
puts

if final_installation == 'Kirvano' && final_brand == 'Kirvano'
  puts "✅ SUCESSO: Configurações do servidor estão corretas!"
  puts "   O título agora DEVE mostrar 'Kirvano'"
  puts "   Se ainda mostrar 'Chatwoot', é cache do navegador."
else
  puts "❌ ERRO: Algo deu errado na configuração"
  puts "   Por favor, execute o script novamente"
end
puts
puts "💡 DICA: Se o problema persistir após todos os passos,"
puts "   pode ser necessário reiniciar o servidor Rails."
