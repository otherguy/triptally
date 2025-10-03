require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "custom validations" do
    context "end_date_after_start_date validation" do
      it "is valid when end_date is after start_date" do
        trip = build(:trip, start_date: Date.today, end_date: Date.today + 1.day)
        expect(trip).to be_valid
      end

      it "is valid when dates are not provided" do
        trip = build(:trip, :without_dates)
        expect(trip).to be_valid
      end

      it "is invalid when end_date is before start_date" do
        trip = build(:trip, :with_invalid_dates)
        expect(trip).not_to be_valid
        expect(trip.errors[:end_date]).to include("must be after start date")
      end

      it "is valid when end_date equals start_date" do
        trip = build(:trip, start_date: Date.today, end_date: Date.today)
        expect(trip).to be_valid
      end
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:trip)).to be_valid
    end

    it "creates valid trips with different traits" do
      expect(build(:trip, :without_dates)).to be_valid
      expect(build(:trip, :past_trip)).to be_valid
      expect(build(:trip, :ongoing_trip)).to be_valid
    end
  end
end
