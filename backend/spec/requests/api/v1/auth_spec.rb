# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let(:valid_user_attributes) do
    {
      name: "John Doe",
      email: "john@example.com",
      password: "password123",
    }
  end

  describe "POST /api/v1/auth/register" do
    context "with valid parameters" do
      it "creates a new user and returns a token" do
        expect {
          post "/api/v1/auth/register", params: valid_user_attributes, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["message"]).to eq("User created successfully")
        expect(json_response["token"]).to be_present
        expect(json_response["user"]["email"]).to eq("john@example.com")
        expect(json_response["user"]["name"]).to eq("John Doe")
        expect(json_response["user"]["id"]).to be_present
      end
    end

    context "with missing parameters" do
      it "returns error when name is missing" do
        post "/api/v1/auth/register",
             params: { email: "john@example.com", password: "password123" },
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("name")
      end

      it "returns error when email is missing" do
        post "/api/v1/auth/register",
             params: { name: "John Doe", password: "password123" },
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("email")
      end

      it "returns error when password is missing" do
        post "/api/v1/auth/register",
             params: { name: "John Doe", email: "john@example.com" },
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("password")
      end
    end

    context "with invalid parameters" do
      it "returns error when email is invalid" do
        post "/api/v1/auth/register",
             params: valid_user_attributes.merge(email: "invalid_email"),
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end

      it "returns error when password is too short" do
        post "/api/v1/auth/register",
             params: valid_user_attributes.merge(password: "short"),
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Password is too short (minimum is 6 characters)")
      end

      it "returns error when email is already taken" do
        create(:user, email: "john@example.com")

        post "/api/v1/auth/register", params: valid_user_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Email has already been taken")
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "john@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns a token and user information" do
        post "/api/v1/auth/login",
             params: { email: "john@example.com", password: "password123" },
             as: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["message"]).to eq("Login successful")
        expect(json_response["token"]).to be_present
        expect(json_response["user"]["email"]).to eq("john@example.com")
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "returns error with invalid email" do
        post "/api/v1/auth/login",
             params: { email: "wrong@example.com", password: "password123" },
             as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response["error"]).to eq("Invalid email or password")
      end

      it "returns error with invalid password" do
        post "/api/v1/auth/login",
             params: { email: "john@example.com", password: "wrongpassword" },
             as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response["error"]).to eq("Invalid email or password")
      end
    end

    context "with missing parameters" do
      it "returns error when email is missing" do
        post "/api/v1/auth/login",
             params: { password: "password123" },
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("email")
      end

      it "returns error when password is missing" do
        post "/api/v1/auth/login",
             params: { email: "john@example.com" },
             as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response["error"]).to include("password")
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let(:user) { create(:user) }

    it "returns success message when authenticated" do
      delete "/api/v1/auth/logout", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body
      expect(json_response["message"]).to eq("Logged out successfully")
    end

    it "returns error when not authenticated" do
      delete "/api/v1/auth/logout"

      expect(response).to have_http_status(:unauthorized)
      json_response = response.parsed_body
      expect(json_response["error"]).to eq("Missing token")
    end
  end
end
