class Api::V1::UsersController < Api::V1::BaseController
  def show
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        created_at: current_user.created_at,
      },
    }
  end

  def update
    user_params = update_user_params
    return if performed?

    if current_user.update(user_params)
      render json: {
        message: "Profile updated successfully",
        user: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
        },
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def replace
    user_params = replace_user_params
    return if performed?

    # For PUT, we replace all attributes (clear non-provided optional fields)
    # Since name and email are both required for a user, we require both
    replacement_attributes = {
      name: user_params[:name],
      email: user_params[:email],
    }

    if current_user.update(replacement_attributes)
      render json: {
        message: "Profile replaced successfully",
        user: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
        },
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def update_user_params
    permitted_params = [ :name, :email ]
    user_params = params.permit(*permitted_params)

    # Check if at least one parameter is provided for update
    if user_params.keys.empty?
      render json: { error: "At least one parameter must be provided for update" }, status: :bad_request
      return
    end

    user_params
  end

  def replace_user_params
    required_params = [ :name, :email ]
    permitted_params = params.permit(:name, :email)

    # For PUT, both name and email are required
    missing_params = required_params - permitted_params.keys.map(&:to_sym)
    if missing_params.any?
      render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
      return
    end

    permitted_params
  end
end
