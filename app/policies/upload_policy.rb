class UploadPolicy < ApplicationPolicy
  def create?
    @account_user.administrator? || @account_user.agent?
  end
end

UploadPolicy.prepend_mod_with('UploadPolicy')