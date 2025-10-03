require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:trips).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value("user@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_secure_password }
  end

  describe "password validations" do
    context "when creating a new user" do
      it "requires password to be at least 6 characters" do
        user = build(:user, password: "short", password_confirmation: "short")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it "accepts password with 6 or more characters" do
        user = build(:user, password: "password123", password_confirmation: "password123")
        expect(user).to be_valid
      end
    end

    context "when updating an existing user" do
      let(:user) { create(:user) }

      it "does not require password if not changing it" do
        user.name = "New Name"
        expect(user).to be_valid
      end

      it "validates password length if password is being changed" do
        user.password = "short"
        user.password_confirmation = "short"
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end
    end
  end

  describe "associations cascade" do
    it "destroys associated trips when user is destroyed" do
      user = create(:user, :with_trips)
      expect { user.destroy }.to change(Trip, :count).by(-3)
    end
  end
end
