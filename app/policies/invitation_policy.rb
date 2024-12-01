class InvitationPolicy < ApplicationPolicy
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
        scope.joins(:card).where(cards: { user_id: user.id })
      end
    end
  end

  def index?
    true
  end

  def show?
    record.card.user == user || record.guest_email == user.email
  end

  def create?
    record.card.user == user && record.card.published?
  end

  def destroy?
    record.card.user == user && !record.responded?
  end

  def accept?
    record.guest_email == user.email && record.pending?
  end

  def decline?
    record.guest_email == user.email && record.pending?
  end

  def resend?
    record.card.user == user && record.pending?
  end
end
