class UploadPolicy < ApplicationPolicy
  def create?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end
end

UploadPolicy.prepend_mod_with('UploadPolicy')