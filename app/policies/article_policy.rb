class ArticlePolicy < ApplicationPolicy
  def index?
    @account.users.include?(@user)
  end

  def update?
    @account_user.administrator? || @account_user.agent?
  end

  def show?
    @account_user.administrator? || @account_user.agent?
  end

  def edit?
    @account_user.administrator? || @account_user.agent?
  end

  def create?
    @account_user.administrator? || @account_user.agent?
  end

  def destroy?
    @account_user.administrator? || @account_user.agent?
  end

  def reorder?
    @account_user.administrator?
  end
end

ArticlePolicy.prepend_mod_with('ArticlePolicy')
