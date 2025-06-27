#!/usr/bin/env ruby
# Script para forçar atualização completa do título da aba do navegador
# Execute com: rails runner db/scripts/force_title_update.rb

puts "🔧 Iniciando atualização forçada do título da aba..."
puts

# 1. Verificar configurações atuais
puts "1️⃣ Verificando configurações atuais:"
installation_name = InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.value
brand_name = InstallationConfig.find_by(name: 'BRAND_NAME')&.value

puts "   INSTALLATION_NAME: #{installation_name}"
puts "   BRAND_NAME: #{brand_name}"
puts

# 2. Atualizar se necessário
if installation_name != 'Kirvano'
  puts "2️⃣ Atualizando INSTALLATION_NAME para 'Kirvano'..."
  InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.update(value: 'Kirvano')
  puts "   ✅ INSTALLATION_NAME atualizado"
else
  puts "2️⃣ INSTALLATION_NAME já está correto: #{installation_name}"
end

if brand_name != 'Kirvano'
  puts "   Atualizando BRAND_NAME para 'Kirvano'..."
  InstallationConfig.find_by(name: 'BRAND_NAME')&.update(value: 'Kirvano')
  puts "   ✅ BRAND_NAME atualizado"
else
  puts "   BRAND_NAME já está correto: #{brand_name}"
end
puts

# 3. Limpar caches
puts "3️⃣ Limpando todos os caches..."
Rails.cache.clear
begin
  ActionController::Base.new.expire_fragment(/.*/)
rescue => e
  puts "   ⚠️  Fragment cache: #{e.message}"
end
puts "   ✅ Caches limpos"
puts

# 4. Verificar configurações finais
puts "4️⃣ Verificação final:"
final_installation = InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.value
final_brand = InstallationConfig.find_by(name: 'BRAND_NAME')&.value

puts "   INSTALLATION_NAME: #{final_installation}"
puts "   BRAND_NAME: #{final_brand}"
puts

if final_installation == 'Kirvano' && final_brand == 'Kirvano'
  puts "🎉 Sucesso! Configurações atualizadas para 'Kirvano'"
  puts
  puts "📋 Próximos passos:"
  puts "   1. Recarregue a página no navegador (Ctrl+F5 ou Cmd+Shift+R)"
  puts "   2. Se ainda aparecer 'Chatwoot', limpe o cache do navegador"
  puts "   3. Teste em modo incógnito/privado"
  puts "   4. O título da aba deve mostrar 'Kirvano'"
else
  puts "❌ Erro: Configurações não foram atualizadas corretamente"
end
