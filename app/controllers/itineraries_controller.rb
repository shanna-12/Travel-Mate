class ItinerariesController < ApplicationController
  def new
    @itinerary = Itinerary.new
    @mode = params[:mode]
  end

  def create
    @itinerary = Itinerary.new(itinerary_params)
    @itinerary.user = current_user

    if @itinerary.save
      redirect_to itinerary_path(@itinerary)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @itinerary = Itinerary.find(params[:id])
    @chats = @itinerary.chats.where(user: current_user)
  end

  private

  def itinerary_params
    params.require(:itinerary).permit(
      :destination,
      :holiday_type,
      :start_date,
      :end_date,
      :adults,
      :children,
      :budget
    )
  end
end
