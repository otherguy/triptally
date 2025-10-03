class Api::V1::BaseController < ApplicationController
  before_action :authenticate_request!

  private

  def authenticate_request!
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'Missing token' }, status: :unauthorized unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
