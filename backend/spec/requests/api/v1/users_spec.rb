# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/users/me" do
    context "when authenticated" do
      it "returns current user information" do
        get "/api/v1/users/me", headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["user"]["id"]).to eq(user.id)
        expect(json_response["user"]["name"]).to eq(user.name)
        expect(json_response["user"]["email"]).to eq(user.email)
        expect(json_response["user"]["created_at"]).to be_present
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        get "/api/v1/users/me"

        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response["error"]).to eq("Missing token")
      end
    end

    context "with invalid token" do
      it "returns unauthorized error" do
        get "/api/v1/users/me", headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response["error"]).to eq("Invalid token")
      end
    end
  end

  describe "PATCH /api/v1/users/me" do
    context "when authenticated" do
      it "updates user name" do
        patch "/api/v1/users/me",
              params: { name: "New Name" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["message"]).to eq("Profile updated successfully")
        expect(json_response["user"]["name"]).to eq("New Name")
        expect(json_response["user"]["email"]).to eq(user.email)
      end

      it "updates user email" do
        patch "/api/v1/users/me",
              params: { email: "newemail@example.com" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["message"]).to eq("Profile updated successfully")
        expect(json_response["user"]["email"]).to eq("newemail@example.com")
        expect(json_response["user"]["name"]).to eq(user.name)
      end

      it "updates both name and email" do
        patch "/api/v1/users/me",
              params: { name: "New Name", email: "newemail@example.com" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["user"]["name"]).to eq("New Name")
        expect(json_response["user"]["email"]).to eq("newemail@example.com")
      end

      it "returns error when no parameters are provided" do
        patch "/api/v1/users/me",
              params: {},
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("At least one parameter must be provided")
      end

      it "returns error with invalid email format" do
        patch "/api/v1/users/me",
              params: { email: "invalid_email" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end

      it "returns error when email is already taken" do
        other_user = create(:user, email: "taken@example.com")

        patch "/api/v1/users/me",
              params: { email: "taken@example.com" },
              headers: auth_headers(user),
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Email has already been taken")
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        patch "/api/v1/users/me", params: { name: "New Name" }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/users/me" do
    context "when authenticated" do
      it "replaces user profile with all required fields" do
        put "/api/v1/users/me",
            params: { name: "Replaced Name", email: "replaced@example.com" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["message"]).to eq("Profile replaced successfully")
        expect(json_response["user"]["name"]).to eq("Replaced Name")
        expect(json_response["user"]["email"]).to eq("replaced@example.com")
      end

      it "returns error when name is missing" do
        put "/api/v1/users/me",
            params: { email: "replaced@example.com" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("name")
      end

      it "returns error when email is missing" do
        put "/api/v1/users/me",
            params: { name: "Replaced Name" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("email")
      end

      it "returns error when both fields are missing" do
        put "/api/v1/users/me",
            params: {},
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("name")
        expect(json_response["error"]).to include("email")
      end

      it "returns error with invalid email format" do
        put "/api/v1/users/me",
            params: { name: "Replaced Name", email: "invalid_email" },
            headers: auth_headers(user),
            as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "when not authenticated" do
      it "returns unauthorized error" do
        put "/api/v1/users/me",
            params: { name: "Replaced Name", email: "replaced@example.com" },
            as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
