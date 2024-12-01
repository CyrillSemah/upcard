require 'rails_helper'

RSpec.describe TemplatePolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:active_template) { create(:template, active: true) }
  let(:inactive_template) { create(:template, active: false) }

  permissions :index? do
    it "allows access to anyone" do
      expect(subject).to permit(user, Template)
      expect(subject).to permit(nil, Template)
    end
  end

  permissions :show? do
    it "allows access to active templates" do
      expect(subject).to permit(user, active_template)
    end

    it "denies access to inactive templates" do
      expect(subject).not_to permit(user, inactive_template)
    end
  end

  permissions :create?, :update?, :destroy? do
    it "allows access to admin users" do
      expect(subject).to permit(admin, Template)
    end

    it "denies access to regular users" do
      expect(subject).not_to permit(user, Template)
    end

    it "denies access to guests" do
      expect(subject).not_to permit(nil, Template)
    end
  end

  permissions :activate?, :deactivate? do
    it "allows access to admin users" do
      expect(subject).to permit(admin, Template)
    end

    it "denies access to regular users" do
      expect(subject).not_to permit(user, Template)
    end
  end

  describe "Scope" do
    let!(:active_template) { create(:template, active: true) }
    let!(:inactive_template) { create(:template, active: false) }

    it "shows only active templates" do
      scope = TemplatePolicy::Scope.new(user, Template).resolve
      expect(scope).to include(active_template)
      expect(scope).not_to include(inactive_template)
    end

    it "shows only active templates even for admin" do
      scope = TemplatePolicy::Scope.new(admin, Template).resolve
      expect(scope).to include(active_template)
      expect(scope).not_to include(inactive_template)
    end
  end
end
