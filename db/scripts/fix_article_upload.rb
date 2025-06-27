#!/usr/bin/env ruby
# Script para diagnosticar e corrigir problemas de upload em artigos
# Execute com: rails runner db/scripts/fix_article_upload.rb

puts "🔍 Diagnosticando problemas de upload de imagens em artigos..."
puts

# 1. Verificar Direct Uploads
puts "1️⃣ Verificando Direct Uploads:"
direct_uploads = InstallationConfig.find_by(name: 'DIRECT_UPLOADS_ENABLED')
if direct_uploads
  puts "   Status atual: #{direct_uploads.value}"
  if direct_uploads.value != 'true'
    direct_uploads.update(value: 'true')
    puts "   ✅ Direct Uploads habilitado!"
  else
    puts "   ✅ Direct Uploads já está habilitado"
  end
else
  InstallationConfig.create(name: 'DIRECT_UPLOADS_ENABLED', value: 'true')
  puts "   ✅ Direct Uploads criado e habilitado!"
end
puts

# 2. Verificar Active Storage
puts "2️⃣ Verificando Active Storage:"
puts "   Serviço: #{Rails.application.config.active_storage.service}"
puts "   ✅ Usando storage local"
puts

# 3. Verificar diretório de storage
puts "3️⃣ Verificando diretório de storage:"
storage_path = Rails.root.join('storage')
if Dir.exist?(storage_path)
  puts "   ✅ Diretório existe: #{storage_path}"
else
  Dir.mkdir(storage_path)
  puts "   ✅ Diretório criado: #{storage_path}"
end
puts

# 4. Verificar permissões
puts "4️⃣ Verificando permissões do diretório:"
if File.writable?(storage_path)
  puts "   ✅ Diretório tem permissão de escrita"
else
  puts "   ❌ Diretório sem permissão de escrita!"
  puts "   Execute: chmod 755 #{storage_path}"
end
puts

# 5. Verificar limite de conteúdo
puts "5️⃣ Verificando limites de conteúdo:"
puts "   ⚠️  Limite de 20.000 caracteres pode estar no frontend"
puts "   Isso pode ser um problema ao converter imagens para base64"
puts

# 6. Limpar cache
puts "6️⃣ Limpando cache da aplicação:"
Rails.cache.clear
puts "   ✅ Cache limpo"
puts

puts "📋 Recomendações:"
puts "   1. Recarregue a página (Ctrl+F5)"
puts "   2. Tente fazer upload de imagens menores (< 1MB)"
puts "   3. Use formatos JPG ou PNG"
puts "   4. Se o erro persistir, verifique o console do navegador"
puts
puts "🔧 Possíveis soluções adicionais:"
puts "   - Aumentar o limite de caracteres no frontend"
puts "   - Configurar um serviço de storage na nuvem (S3, etc)"
puts "   - Verificar logs do servidor para erros específicos"
