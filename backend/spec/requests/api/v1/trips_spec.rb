# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Trips", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:trip) { create(:trip, user: user) }

  describe "GET /api/v1/trips" do
    context "when authenticated" do
      before do
        create_list(:trip, 3, user: user)
        create_list(:trip, 2, user: other_user)
      end

      it "returns only current user's trips" do
        get "/api/v1/trips", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["trips"].size).to eq(3)
        json_response["trips"].each do |trip|
          expect(Trip.find(trip["id"]).user_id).to eq(user.id)
        end
      end

      it "returns trips ordered by created_at descending" do
        get "/api/v1/trips", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        created_at_values = json_response["trips"].map { |t| Time.parse(t["created_at"]) }
        expect(created_at_values).to eq(created_at_values.sort.reverse)
      end

      it "returns empty array when user has no trips" do
        user_without_trips = create(:user)
        get "/api/v1/trips", headers: auth_headers(user_without_trips)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["trips"]).to eq([])
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        get "/api/v1/trips"

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Missing token")
      end
    end
  end

  describe "GET /api/v1/trips/:id" do
    context "when authenticated" do
      it "returns the trip details" do
        get "/api/v1/trips/#{trip.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["trip"]["id"]).to eq(trip.id)
        expect(json_response["trip"]["title"]).to eq(trip.title)
        expect(json_response["trip"]["description"]).to eq(trip.description)
        expect(json_response["trip"]["start_date"]).to be_present
        expect(json_response["trip"]["end_date"]).to be_present
        expect(json_response["trip"]["created_at"]).to be_present
        expect(json_response["trip"]["updated_at"]).to be_present
      end

      it "returns not found error when trip does not exist" do
        get "/api/v1/trips/99999", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Trip not found")
      end

      it "returns not found error when trying to access another user's trip" do
        other_trip = create(:trip, user: other_user)
        get "/api/v1/trips/#{other_trip.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Trip not found")
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        get "/api/v1/trips/#{trip.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/trips" do
    let(:valid_trip_attributes) do
      {
        title: "Summer Vacation",
        description: "Trip to the beach",
        start_date: Date.tomorrow,
        end_date: Date.tomorrow + 7.days,
      }
    end

    context "when authenticated" do
      it "creates a new trip with all fields" do
        expect {
          post "/api/v1/trips",
               params: valid_trip_attributes,
               headers: auth_headers(user),
               as: :json
        }.to change(Trip, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Trip created successfully")
        expect(json_response["trip"]["title"]).to eq("Summer Vacation")
        expect(json_response["trip"]["description"]).to eq("Trip to the beach")
        expect(json_response["trip"]["id"]).to be_present

        created_trip = Trip.last
        expect(created_trip.user_id).to eq(user.id)
      end

      it "creates a trip with only required fields" do
        expect {
          post "/api/v1/trips",
               params: { title: "Quick Trip" },
               headers: auth_headers(user),
               as: :json
        }.to change(Trip, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["trip"]["title"]).to eq("Quick Trip")
        expect(json_response["trip"]["description"]).to be_nil
        expect(json_response["trip"]["start_date"]).to be_nil
        expect(json_response["trip"]["end_date"]).to be_nil
      end

      it "returns error when title is missing" do
        post "/api/v1/trips",
             params: { description: "No title trip" },
             headers: auth_headers(user),
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("title")
      end

      it "returns error when end_date is before start_date" do
        post "/api/v1/trips",
             params: {
               title: "Invalid Trip",
               start_date: Date.tomorrow,
               end_date: Date.today,
             },
             headers: auth_headers(user),
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("End date must be after start date")
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        post "/api/v1/trips", params: valid_trip_attributes, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/trips/:id" do
    context "when authenticated" do
      it "updates trip title" do
        patch "/api/v1/trips/#{trip.id}",
              params: { title: "Updated Title" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Trip updated successfully")
        expect(json_response["trip"]["title"]).to eq("Updated Title")
        expect(trip.reload.title).to eq("Updated Title")
      end

      it "updates trip description" do
        patch "/api/v1/trips/#{trip.id}",
              params: { description: "Updated description" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["trip"]["description"]).to eq("Updated description")
      end

      it "updates trip dates" do
        new_start = Date.tomorrow
        new_end = Date.tomorrow + 5.days

        patch "/api/v1/trips/#{trip.id}",
              params: { start_date: new_start, end_date: new_end },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(Date.parse(json_response["trip"]["start_date"])).to eq(new_start)
        expect(Date.parse(json_response["trip"]["end_date"])).to eq(new_end)
      end

      it "returns error when no parameters are provided" do
        patch "/api/v1/trips/#{trip.id}",
              params: {},
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("At least one parameter must be provided")
      end

      it "returns error when updating to invalid dates" do
        patch "/api/v1/trips/#{trip.id}",
              params: { start_date: Date.tomorrow, end_date: Date.today },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("End date must be after start date")
      end

      it "returns not found when trying to update another user's trip" do
        other_trip = create(:trip, user: other_user)

        patch "/api/v1/trips/#{other_trip.id}",
              params: { title: "Hacked" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        patch "/api/v1/trips/#{trip.id}", params: { title: "Updated" }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/trips/:id" do
    context "when authenticated" do
      it "replaces trip with all required fields" do
        put "/api/v1/trips/#{trip.id}",
            params: {
              title: "Replaced Trip",
              description: "New description",
              start_date: Date.tomorrow,
              end_date: Date.tomorrow + 3.days,
            },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Trip replaced successfully")
        expect(json_response["trip"]["title"]).to eq("Replaced Trip")
        expect(json_response["trip"]["description"]).to eq("New description")
      end

      it "replaces trip and clears optional fields when not provided" do
        trip.update(description: "Old description", start_date: Date.today, end_date: Date.today + 1)

        put "/api/v1/trips/#{trip.id}",
            params: { title: "Minimal Trip", description: nil, start_date: nil, end_date: nil },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["trip"]["title"]).to eq("Minimal Trip")
        expect(json_response["trip"]["description"]).to be_nil
        expect(json_response["trip"]["start_date"]).to be_nil
        expect(json_response["trip"]["end_date"]).to be_nil
      end

      it "returns error when title is missing" do
        put "/api/v1/trips/#{trip.id}",
            params: { description: "Only description" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("title")
      end

      it "returns error when dates are invalid" do
        put "/api/v1/trips/#{trip.id}",
            params: {
              title: "Invalid dates",
              start_date: Date.tomorrow,
              end_date: Date.today,
            },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("End date must be after start date")
      end

      it "returns not found when trying to replace another user's trip" do
        other_trip = create(:trip, user: other_user)

        put "/api/v1/trips/#{other_trip.id}",
            params: { title: "Hacked" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        put "/api/v1/trips/#{trip.id}", params: { title: "Replaced" }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/trips/:id" do
    context "when authenticated" do
      it "deletes the trip" do
        trip_to_delete = create(:trip, user: user)

        expect {
          delete "/api/v1/trips/#{trip_to_delete.id}", headers: auth_headers(user)
        }.to change(Trip, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Trip deleted successfully")
      end

      it "returns not found when trip does not exist" do
        delete "/api/v1/trips/99999", headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Trip not found")
      end

      it "returns not found when trying to delete another user's trip" do
        other_trip = create(:trip, user: other_user)

        expect {
          delete "/api/v1/trips/#{other_trip.id}", headers: auth_headers(user)
        }.not_to change(Trip, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        delete "/api/v1/trips/#{trip.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
