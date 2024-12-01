class CardPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  def index?
    true
  end

  def show?
    record.user == user || record.invitations.exists?(guest_email: user.email)
  end

  def create?
    user.present?
  end

  def update?
    record.user == user && !record.published?
  end

  def destroy?
    record.user == user && !record.published?
  end

  def publish?
    record.user == user && !record.published?
  end

  def archive?
    record.user == user && record.published?
  end

  def send_invitations?
    record.user == user && record.published?
  end
end
