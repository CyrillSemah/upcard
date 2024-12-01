require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      template = build(:template)
      expect(template).to be_valid
    end

    it 'is not valid without a name' do
      template = build(:template, name: nil)
      expect(template).not_to be_valid
    end

    it 'is not valid without a category' do
      template = build(:template, category: nil)
      expect(template).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many cards' do
      template = create(:template)
      card1 = create(:card, template: template)
      card2 = create(:card, template: template)
      
      expect(template.cards).to include(card1, card2)
    end
  end

  describe 'scopes' do
    it 'returns only active templates' do
      active_template = create(:template, active: true)
      inactive_template = create(:template, active: false)
      
      expect(Template.active).to include(active_template)
      expect(Template.active).not_to include(inactive_template)
    end

    it 'filters by category' do
      wedding_template = create(:template, category: :wedding)
      birthday_template = create(:template, category: :birthday)
      
      expect(Template.by_category(:wedding)).to include(wedding_template)
      expect(Template.by_category(:wedding)).not_to include(birthday_template)
    end
  end

  describe 'instance methods' do
    let(:template) { create(:template, active: true) }

    describe '#deactivate!' do
      it 'sets active to false' do
        template.deactivate!
        expect(template.reload).not_to be_active
      end
    end

    describe '#activate!' do
      it 'sets active to true' do
        template.update(active: false)
        template.activate!
        expect(template.reload).to be_active
      end
    end
  end
end
