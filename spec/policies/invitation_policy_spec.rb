require 'rails_helper'

RSpec.describe InvitationPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:card) { create(:card, :published, user: user) }
  let(:invitation) { create(:invitation, card: card) }
  let(:others_invitation) { create(:invitation, card: create(:card, user: other_user)) }

  permissions :index? do
    it "allows access to any user" do
      expect(subject).to permit(user, Invitation)
      expect(subject).to permit(nil, Invitation)
    end
  end

  permissions :show? do
    it "allows access to card owner" do
      expect(subject).to permit(user, invitation)
    end

    it "allows access to invited user" do
      invitation = create(:invitation, guest_email: user.email)
      expect(subject).to permit(user, invitation)
    end

    it "denies access to other users" do
      expect(subject).not_to permit(other_user, invitation)
    end
  end

  permissions :create? do
    context "with published card" do
      it "allows creation by card owner" do
        expect(subject).to permit(user, invitation)
      end

      it "denies creation by other users" do
        expect(subject).not_to permit(other_user, invitation)
      end
    end

    context "with draft card" do
      let(:draft_card) { create(:card, user: user) }
      let(:draft_invitation) { build(:invitation, card: draft_card) }

      it "denies creation even by card owner" do
        expect(subject).not_to permit(user, draft_invitation)
      end
    end
  end

  permissions :destroy? do
    it "allows deletion by card owner if not responded" do
      expect(subject).to permit(user, invitation)
    end

    it "denies deletion by card owner if responded" do
      responded_invitation = create(:invitation, :responded, card: card)
      expect(subject).not_to permit(user, responded_invitation)
    end

    it "denies deletion by other users" do
      expect(subject).not_to permit(other_user, invitation)
    end
  end

  permissions :accept?, :decline? do
    let(:invitation_for_user) { create(:invitation, guest_email: user.email) }

    it "allows response by invited user" do
      expect(subject).to permit(user, invitation_for_user)
    end

    it "denies response by other users" do
      expect(subject).not_to permit(other_user, invitation_for_user)
    end

    it "denies response if already responded" do
      responded_invitation = create(:invitation, :responded, guest_email: user.email)
      expect(subject).not_to permit(user, responded_invitation)
    end
  end

  permissions :resend? do
    it "allows resend by card owner if pending" do
      expect(subject).to permit(user, invitation)
    end

    it "denies resend by card owner if responded" do
      responded_invitation = create(:invitation, :responded, card: card)
      expect(subject).not_to permit(user, responded_invitation)
    end

    it "denies resend by other users" do
      expect(subject).not_to permit(other_user, invitation)
    end
  end

  describe "Scope" do
    let!(:user_invitation) { create(:invitation, card: card) }
    let!(:other_invitation) { create(:invitation, card: create(:card, user: other_user)) }

    it "shows only user's card invitations for regular users" do
      scope = InvitationPolicy::Scope.new(user, Invitation).resolve
      expect(scope).to include(user_invitation)
      expect(scope).not_to include(other_invitation)
    end

    it "shows all invitations for admins" do
      scope = InvitationPolicy::Scope.new(admin, Invitation).resolve
      expect(scope).to include(user_invitation, other_invitation)
    end
  end
end
