# == Schema Information
#
# Table name: installation_configs
#
#  id               :bigint           not null, primary key
#  locked           :boolean          default(TRUE), not null
#  name             :string           not null
#  serialized_value :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_installation_configs_on_name                 (name) UNIQUE
#  index_installation_configs_on_name_and_created_at  (name,created_at) UNIQUE
#
class InstallationConfig < ApplicationRecord
  # https://stackoverflow.com/questions/72970170/upgrading-to-rails-6-1-6-1-causes-psychdisallowedclass-tried-to-load-unspecif
  # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
  # FIX ME : fixes breakage of installation config. we need to migrate.
  # Fix configuration in application.rb
  serialize :serialized_value, coder: YAML, type: ActiveSupport::HashWithIndifferentAccess

  before_validation :set_lock
  validates :name, presence: true

  # TODO: Get rid of default scope
  # https://stackoverflow.com/a/1834250/939299
  default_scope { order(created_at: :desc) }
  scope :editable, -> { where(locked: false) }

  after_commit :clear_cache

  def value
    # This is an extra hack again cause of the YAML serialization, in case of new object initialization in super admin
    # It was throwing error as the default value of column '{}' was failing in deserialization.
    return {}.with_indifferent_access if new_record? && @attributes['serialized_value']&.value_before_type_cast == '{}'

    begin
      # Handle case where serialized_value is already the direct value (incorrect format from database)
      if serialized_value.is_a?(String) 
        # Direct string value stored incorrectly - fix it
        Rails.logger.warn "InstallationConfig #{name}: Direct string value detected, auto-fixing: #{serialized_value}"
        self.value = serialized_value
        save! if persisted?
        return serialized_value
      elsif serialized_value.is_a?(Hash) && serialized_value.key?(:value)
        serialized_value[:value]
      elsif serialized_value.is_a?(Hash) && serialized_value.key?('value')
        val = serialized_value['value']
        if val.present?
          Rails.logger.warn "InstallationConfig #{name}: String key detected, auto-fixing to symbol key"
          self.value = val
          save! if persisted?
        end
        val
      else
        Rails.logger.warn "InstallationConfig #{name}: Unexpected serialized_value format: #{serialized_value.inspect}"
        nil
      end
    rescue => e
      Rails.logger.error "InstallationConfig #{name}: Error accessing value: #{e.message}"
      Rails.logger.error "serialized_value: #{serialized_value.inspect}"
      nil
    end
  end

  def value=(value_to_assigned)
    self.serialized_value = {
      value: value_to_assigned
    }.with_indifferent_access
  end

  private

  def set_lock
    self.locked = true if locked.nil?
  end

  def clear_cache
    GlobalConfig.clear_cache
  end
end
