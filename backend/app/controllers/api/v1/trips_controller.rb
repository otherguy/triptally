class Api::V1::TripsController < Api::V1::BaseController
  before_action :set_trip, only: [:show, :update, :replace, :destroy]

  def index
    trips = current_user.trips.order(created_at: :desc)
    render json: {
      trips: trips.map { |trip| trip_response(trip) }
    }
  end

  def show
    render json: {
      trip: trip_response(@trip)
    }
  end

  def create
    trip_params = create_trip_params
    return if performed?

    trip = current_user.trips.build(trip_params)

    if trip.save
      render json: {
        message: 'Trip created successfully',
        trip: trip_response(trip)
      }, status: :created
    else
      render json: { errors: trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    trip_params = update_trip_params
    return if performed?

    if @trip.update(trip_params)
      render json: {
        message: 'Trip updated successfully',
        trip: trip_response(@trip)
      }
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def replace
    trip_params = replace_trip_params
    return if performed?

    # For PUT, we replace all attributes (clear non-provided optional fields)
    replacement_attributes = {
      title: trip_params[:title],
      description: trip_params[:description],
      start_date: trip_params[:start_date],
      end_date: trip_params[:end_date]
    }

    if @trip.update(replacement_attributes)
      render json: {
        message: 'Trip replaced successfully',
        trip: trip_response(@trip)
      }
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    render json: { message: 'Trip deleted successfully' }
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Trip not found' }, status: :not_found
  end

  def create_trip_params
    required_params = [:title]
    permitted_params = params.permit(:title, :description, :start_date, :end_date)

    missing_params = required_params - permitted_params.keys.map(&:to_sym)
    if missing_params.any?
      render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
      return
    end

    permitted_params
  end

  def update_trip_params
    permitted_params = [:title, :description, :start_date, :end_date]
    trip_params = params.permit(*permitted_params)

    # Check if at least one parameter is provided for update
    if trip_params.keys.empty?
      render json: { error: 'At least one parameter must be provided for update' }, status: :bad_request
      return
    end

    trip_params
  end

  def replace_trip_params
    required_params = [:title]
    permitted_params = params.permit(:title, :description, :start_date, :end_date)

    # For PUT, title is required
    missing_params = required_params - permitted_params.keys.map(&:to_sym)
    if missing_params.any?
      render json: { error: "Missing required parameters: #{missing_params.join(', ')}" }, status: :bad_request
      return
    end

    permitted_params
  end

  def trip_response(trip)
    {
      id: trip.id,
      title: trip.title,
      description: trip.description,
      start_date: trip.start_date,
      end_date: trip.end_date,
      created_at: trip.created_at,
      updated_at: trip.updated_at
    }
  end
end