# Script para atualizar o nome da instalação no banco de dados
# Execute com: rails runner db/scripts/update_installation_name.rb

puts "Atualizando configurações de marca no banco de dados..."

# Atualizar INSTALLATION_NAME
installation_config = InstallationConfig.find_by(name: 'INSTALLATION_NAME')
if installation_config
  installation_config.update(value: 'Kirvano')
  puts "✅ INSTALLATION_NAME atualizado para: #{installation_config.value}"
else
  puts "❌ INSTALLATION_NAME não encontrado no banco de dados"
end

# Atualizar BRAND_NAME
brand_config = InstallationConfig.find_by(name: 'BRAND_NAME')
if brand_config
  brand_config.update(value: 'Kirvano')
  puts "✅ BRAND_NAME atualizado para: #{brand_config.value}"
else
  puts "❌ BRAND_NAME não encontrado no banco de dados"
end

# Limpar cache
Rails.cache.clear
puts "✅ Cache da aplicação limpo"

puts "\n🎉 Configurações atualizadas com sucesso!"
puts "O título da aba do navegador agora deve exibir 'Kirvano'"
