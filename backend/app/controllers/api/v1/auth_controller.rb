class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_request!, only: [:register, :login]

  def register
    user_params = register_params
    return if performed? # Stop if validation failed

    user = User.new(user_params)

    if user.save
      token = generate_token(user)
      render json: {
        message: 'User created successfully',
        user: user_response(user),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    login_params = login_params_validation
    return if performed? # Stop if validation failed

    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      token = generate_token(user)
      render json: {
        message: 'Login successful',
        user: user_response(user),
        token: token
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    render json: { message: 'Logged out successfully' }
  end

  private

  def register_params
    required_params = [:name, :email, :password]
    permitted_params = params.permit(*required_params)

    missing_params = required_params - permitted_params.keys.map(&:to_sym)
    if missing_params.any?
      render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
      return
    end

    permitted_params
  end

  def login_params_validation
    required_params = [:email, :password]
    permitted_params = params.permit(*required_params)

    missing_params = required_params - permitted_params.keys.map(&:to_sym)
    if missing_params.any?
      render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
      return
    end

    permitted_params
  end

  def generate_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
