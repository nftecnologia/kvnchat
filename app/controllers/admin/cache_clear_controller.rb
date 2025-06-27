# ARQUIVO TEMPORÁRIO - DELETAR APÓS USO
class Admin::CacheClearController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def clear_title_cache
    # Verificar token secreto para segurança
    unless params[:secret_token] == ENV['SECRET_KEY_BASE'][0..20]
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    # Executar o script de limpeza
    result = {
      started_at: Time.current,
      actions: []
    }

    # 1. Atualizar banco de dados
    ['INSTALLATION_NAME', 'BRAND_NAME'].each do |config_name|
      config = InstallationConfig.find_or_create_by(name: config_name)
      if config.value != 'Kirvano'
        config.update(value: 'Kirvano')
        result[:actions] << "#{config_name} atualizado para 'Kirvano'"
      else
        result[:actions] << "#{config_name} já está correto: 'Kirvano'"
      end
    end

    # 2. Limpar caches
    GlobalConfig.clear_cache
    result[:actions] << "GlobalConfig cache limpo"

    # Cache específico do Redis
    ['INSTALLATION_NAME', 'BRAND_NAME'].each do |key|
      cache_key = "V1:GLOBAL_CONFIG:#{key}"
      $alfred.with { |conn| conn.del(cache_key) } rescue nil
      result[:actions] << "Redis cache limpo: #{cache_key}"
    end

    # Limpar TODAS as chaves do GlobalConfig
    begin
      all_keys = $alfred.with { |conn| conn.keys("*GLOBAL_CONFIG*") }
      all_keys.each do |key|
        $alfred.with { |conn| conn.del(key) }
      end
      result[:actions] << "Todas as chaves GlobalConfig removidas (#{all_keys.size} chaves)"
    rescue => e
      result[:actions] << "Erro ao limpar chaves: #{e.message}"
    end

    # Cache do Rails
    Rails.cache.clear
    result[:actions] << "Rails cache limpo"

    # Verificar valores finais
    result[:final_values] = {
      installation_name: GlobalConfig.get_value('INSTALLATION_NAME'),
      brand_name: GlobalConfig.get_value('BRAND_NAME')
    }

    result[:completed_at] = Time.current
    result[:duration] = result[:completed_at] - result[:started_at]

    render json: result
  end
end
