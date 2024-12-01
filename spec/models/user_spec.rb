require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many cards' do
      user = create(:user)
      card1 = create(:card, user: user)
      card2 = create(:card, user: user)
      
      expect(user.cards).to include(card1, card2)
    end

    it 'destroys associated cards when destroyed' do
      user = create(:user)
      create(:card, user: user)
      
      expect { user.destroy }.to change(Card, :count).by(-1)
    end
  end
end
