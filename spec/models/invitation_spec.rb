require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      invitation = build(:invitation)
      expect(invitation).to be_valid
    end

    it 'is not valid without a guest email' do
      invitation = build(:invitation, guest_email: nil)
      expect(invitation).not_to be_valid
    end

    it 'is not valid without a guest name' do
      invitation = build(:invitation, guest_name: nil)
      expect(invitation).not_to be_valid
    end

    it 'is not valid with an invalid email format' do
      invitation = build(:invitation, guest_email: 'invalid_email')
      expect(invitation).not_to be_valid
    end

    it 'generates a token before validation' do
      invitation = build(:invitation, token: nil)
      invitation.valid?
      expect(invitation.token).not_to be_nil
    end
  end

  describe 'associations' do
    it 'belongs to a card' do
      card = create(:card)
      invitation = create(:invitation, card: card)
      expect(invitation.card).to eq(card)
    end
  end

  describe 'scopes' do
    let!(:pending_invitation) { create(:invitation, :pending) }
    let!(:accepted_invitation) { create(:invitation, :accepted) }
    let!(:declined_invitation) { create(:invitation, :declined) }

    it 'returns pending invitations' do
      expect(Invitation.pending).to include(pending_invitation)
      expect(Invitation.pending).not_to include(accepted_invitation, declined_invitation)
    end

    it 'returns accepted invitations' do
      expect(Invitation.accepted).to include(accepted_invitation)
      expect(Invitation.accepted).not_to include(pending_invitation, declined_invitation)
    end

    it 'returns declined invitations' do
      expect(Invitation.declined).to include(declined_invitation)
      expect(Invitation.declined).not_to include(pending_invitation, accepted_invitation)
    end

    it 'returns responded invitations' do
      expect(Invitation.responded).to include(accepted_invitation, declined_invitation)
      expect(Invitation.responded).not_to include(pending_invitation)
    end
  end

  describe 'instance methods' do
    let(:invitation) { create(:invitation) }

    describe '#accept!' do
      it 'changes status to accepted' do
        invitation.accept!
        expect(invitation.reload).to be_accepted
      end
    end

    describe '#decline!' do
      it 'changes status to declined' do
        invitation.decline!
        expect(invitation.reload).to be_declined
      end
    end

    describe '#responded?' do
      it 'returns true for accepted invitations' do
        invitation.accept!
        expect(invitation).to be_responded
      end

      it 'returns true for declined invitations' do
        invitation.decline!
        expect(invitation).to be_responded
      end

      it 'returns false for pending invitations' do
        expect(invitation).not_to be_responded
      end
    end
  end
end
