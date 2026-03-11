class ItinerariesController < ApplicationController
  def new
    @itinerary = Itinerary.new
    @mode = params[:mode]
  end

  def create
    @itinerary = Itinerary.new(itinerary_params)
    @itinerary.user = current_user

    if @itinerary.save

      prompt = <<~PROMPT
        Create a day-wise travel itinerary.

        Destination: #{@itinerary.destination}
        Holiday type: #{@itinerary.holiday_type}
        Start date: #{@itinerary.start_date}
        End date: #{@itinerary.end_date}
        Adults: #{@itinerary.adults}
        Children: #{@itinerary.children}
        Budget: #{@itinerary.budget} euros

        Return the itinerary in Markdown using this format:

        Day 1:
        - Morning:
        - Afternoon:
        - Evening:

        Day 2:
        - Morning:
        - Afternoon:
        - Evening:

        Continue for all days between the start and end date.
      PROMPT

      chat = RubyLLM.chat
      response = chat.ask(prompt)
      @itinerary.update(summary: response.content)
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
