#!/usr/bin/env ruby
# Script para forçar limpeza do cache e atualizar título definitivamente
# Execute com: rails runner db/scripts/force_clear_title_cache.rb

puts "🔧 Forçando atualização do título da aba..."
puts

# 1. Verificar valor atual no banco
puts "1️⃣ Verificando valor no banco de dados:"
installation_name = InstallationConfig.find_by(name: 'INSTALLATION_NAME')
puts "   Valor atual: #{installation_name&.value || 'não encontrado'}"

# 2. Atualizar se necessário
if installation_name.nil?
  InstallationConfig.create(name: 'INSTALLATION_NAME', value: 'Kirvano')
  puts "   ✅ Criado com valor 'Kirvano'"
elsif installation_name.value != 'Kirvano'
  installation_name.update(value: 'Kirvano')
  puts "   ✅ Atualizado para 'Kirvano'"
else
  puts "   ✅ Já está correto: 'Kirvano'"
end
puts

# 3. Limpar cache do GlobalConfig
puts "2️⃣ Limpando cache do GlobalConfig:"
GlobalConfig.clear_cache
puts "   ✅ Cache do GlobalConfig limpo"
puts

# 4. Limpar cache específico do Redis
puts "3️⃣ Limpando cache específico do Redis:"
cache_key = "V1:GLOBAL_CONFIG:INSTALLATION_NAME"
$alfred.with { |conn| conn.del(cache_key) }
puts "   ✅ Cache Redis limpo para: #{cache_key}"
puts

# 5. Limpar todos os caches relacionados
puts "4️⃣ Limpando todos os caches relacionados:"
# Limpar cache do Rails
Rails.cache.clear
puts "   ✅ Rails cache limpo"

# Limpar todos os caches do GlobalConfig
cached_keys = $alfred.with { |conn| conn.keys("V1:GLOBAL_CONFIG:*") }
cached_keys.each do |key|
  $alfred.with { |conn| conn.del(key) }
end
puts "   ✅ Todos os caches GlobalConfig limpos (#{cached_keys.size} chaves)"
puts

# 6. Verificar novo valor
puts "5️⃣ Verificando novo valor após limpeza:"
new_value = GlobalConfig.get_value('INSTALLATION_NAME')
puts "   Novo valor: #{new_value}"
puts

if new_value == 'Kirvano'
  puts "🎉 Sucesso! O título agora está configurado como 'Kirvano'"
  puts
  puts "📋 Próximos passos:"
  puts "   1. Recarregue a página (Ctrl+F5 ou Cmd+Shift+R)"
  puts "   2. O título da aba deve mostrar 'Kirvano'"
  puts "   3. Se ainda mostrar 'Chatwoot', feche o navegador e abra novamente"
  puts "   4. Teste em modo incógnito para confirmar"
else
  puts "❌ Erro: O valor ainda não foi atualizado corretamente"
  puts "   Valor encontrado: #{new_value}"
end
