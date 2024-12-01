require 'rails_helper'

RSpec.describe CardPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  
  let(:draft_card) { create(:card, user: user) }
  let(:published_card) { create(:card, :published, user: user) }
  let(:others_card) { create(:card, user: other_user) }

  permissions :index? do
    it "allows access to any user" do
      expect(subject).to permit(user, Card)
      expect(subject).to permit(nil, Card)
    end
  end

  permissions :show? do
    it "allows access to owner" do
      expect(subject).to permit(user, draft_card)
    end

    it "denies access to non-owners" do
      expect(subject).not_to permit(other_user, draft_card)
    end

    context "when user is invited" do
      let(:card_with_invitation) { create(:card, user: other_user) }
      before { create(:invitation, card: card_with_invitation, guest_email: user.email) }

      it "allows access to invited users" do
        expect(subject).to permit(user, card_with_invitation)
      end
    end
  end

  permissions :create? do
    it "allows creation for logged in users" do
      expect(subject).to permit(user, Card)
    end

    it "denies creation for guests" do
      expect(subject).not_to permit(nil, Card)
    end
  end

  permissions :update?, :destroy? do
    it "allows editing own draft cards" do
      expect(subject).to permit(user, draft_card)
    end

    it "denies editing published cards" do
      expect(subject).not_to permit(user, published_card)
    end

    it "denies editing others' cards" do
      expect(subject).not_to permit(other_user, draft_card)
    end
  end

  permissions :publish? do
    it "allows publishing own draft cards" do
      expect(subject).to permit(user, draft_card)
    end

    it "denies publishing already published cards" do
      expect(subject).not_to permit(user, published_card)
    end

    it "denies publishing others' cards" do
      expect(subject).not_to permit(other_user, draft_card)
    end
  end

  permissions :archive? do
    it "allows archiving own published cards" do
      expect(subject).to permit(user, published_card)
    end

    it "denies archiving draft cards" do
      expect(subject).not_to permit(user, draft_card)
    end

    it "denies archiving others' cards" do
      expect(subject).not_to permit(other_user, published_card)
    end
  end

  permissions :send_invitations? do
    it "allows sending invitations for own published cards" do
      expect(subject).to permit(user, published_card)
    end

    it "denies sending invitations for draft cards" do
      expect(subject).not_to permit(user, draft_card)
    end

    it "denies sending invitations for others' cards" do
      expect(subject).not_to permit(other_user, published_card)
    end
  end

  describe "Scope" do
    let!(:user_card) { create(:card, user: user) }
    let!(:other_card) { create(:card, user: other_user) }
    let!(:admin_card) { create(:card, user: admin) }

    it "shows only user's cards for regular users" do
      scope = CardPolicy::Scope.new(user, Card).resolve
      expect(scope).to include(user_card)
      expect(scope).not_to include(other_card)
    end

    it "shows all cards for admins" do
      scope = CardPolicy::Scope.new(admin, Card).resolve
      expect(scope).to include(user_card, other_card, admin_card)
    end
  end
end
