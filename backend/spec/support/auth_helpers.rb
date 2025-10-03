module AuthHelpers
  def generate_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i,
    }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  def auth_headers(user)
    {
      "Authorization" => "Bearer #{generate_token(user)}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
