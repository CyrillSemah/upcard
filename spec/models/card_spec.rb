require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      card = build(:card)
      expect(card).to be_valid
    end

    it 'is not valid without a title' do
      card = build(:card, title: nil)
      expect(card).not_to be_valid
    end

    it 'is not valid without an event date' do
      card = build(:card, event_date: nil)
      expect(card).not_to be_valid
    end

    it 'is not valid without an event type' do
      card = build(:card, event_type: nil)
      expect(card).not_to be_valid
    end

    it 'requires a template when published' do
      card = build(:card, status: :published, template: nil)
      expect(card).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      card = create(:card, user: user)
      expect(card.user).to eq(user)
    end

    it 'belongs to a template' do
      template = create(:template)
      card = create(:card, template: template)
      expect(card.template).to eq(template)
    end

    it 'has many invitations' do
      card = create(:card, :with_invitations)
      expect(card.invitations.count).to eq(3)
    end
  end

  describe 'scopes' do
    it 'returns active cards' do
      active_card = create(:card, :published)
      draft_card = create(:card, :draft)
      
      expect(Card.active).to include(active_card)
      expect(Card.active).not_to include(draft_card)
    end

    it 'returns upcoming cards' do
      upcoming_card = create(:card, event_date: 1.month.from_now)
      past_card = create(:card, event_date: 1.month.ago)
      
      expect(Card.upcoming).to include(upcoming_card)
      expect(Card.upcoming).not_to include(past_card)
    end

    it 'returns past cards' do
      upcoming_card = create(:card, event_date: 1.month.from_now)
      past_card = create(:card, event_date: 1.month.ago)
      
      expect(Card.past).to include(past_card)
      expect(Card.past).not_to include(upcoming_card)
    end
  end

  describe 'instance methods' do
    describe '#publish!' do
      it 'publishes a card with a template' do
        card = create(:card)
        expect(card.publish!).to be true
        expect(card.reload).to be_published
      end

      it 'does not publish a card without a template' do
        card = create(:card, template: nil)
        expect(card.publish!).to be false
        expect(card.reload).not_to be_published
      end
    end

    describe '#archive!' do
      it 'archives a card' do
        card = create(:card)
        card.archive!
        expect(card.reload).to be_archived
      end
    end

    describe '#response_rate' do
      it 'calculates correct response rate' do
        card = create(:card)
        create_list(:invitation, 2, :accepted, card: card)
        create_list(:invitation, 2, :declined, card: card)
        create_list(:invitation, 4, :pending, card: card)
        
        expect(card.response_rate).to eq(50.0)
      end

      it 'returns 0 for cards without invitations' do
        card = create(:card)
        expect(card.response_rate).to eq(0)
      end
    end
  end
end
