class DebugController < ApplicationController
  # Temporary controller for debugging installation config
  
  def pricing_plan
    config = InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')
    
    render json: {
      current_value: config&.value,
      current_pricing_plan: ChatwootHub.pricing_plan,
      all_installation_configs: InstallationConfig.all.pluck(:name, :serialized_value)
    }
  end
  
  def update_pricing_plan
    config = InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')
    
    if config
      old_value = config.value
      config.update(value: 'enterprise')
      GlobalConfig.clear_cache
      
      render json: {
        success: true,
        old_value: old_value,
        new_value: config.reload.value,
        new_pricing_plan: ChatwootHub.pricing_plan
      }
    else
      render json: { error: 'INSTALLATION_PRICING_PLAN config not found' }
    end
  end
end