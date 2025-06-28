class ArticlePolicy < ApplicationPolicy
  def index?
    @account.users.include?(@user)
  end

  def update?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end

  def show?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end

  def edit?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end

  def create?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end

  def destroy?
    # FIXME: for agent bots, lets bring this validation to policies as well in future
    return true if @user.is_a?(AgentBot)

    @account_user.administrator? || @account_user.agent?
  end

  def reorder?
    @account_user.administrator?
  end
end

ArticlePolicy.prepend_mod_with('ArticlePolicy')
