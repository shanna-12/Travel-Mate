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
        Generate a day-wise travel itinerary in Markdown.

        Destination: #{@itinerary.destination}
        Dates: #{@itinerary.start_date} to #{@itinerary.end_date}
        Type: #{@itinerary.holiday_type}
        Travelers: #{@itinerary.adults} adults, #{@itinerary.children} children
        Budget: #{@itinerary.budget}€

        Format:
        Day 1
        - Morning
        - Afternoon
        - Evening
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
