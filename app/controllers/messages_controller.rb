class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Travel Assistant.\n\nI am looking for travel advise.\n\nHelp me find a holiday itinerary that suits my holiday type.\n\nAnswer concisely in Markdown."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @itinerary = @chat.itinerary

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message # NEW
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def itinerary_context
    "Here is the context of the itinerary: a #{@itinerary.holiday_type} holiday, from #{@itinerary.start_date} to #{@itinerary.end_date}
    with #{@itinerary.adults} adults and #{@itinerary.children} children, buget is #{@itinerary.budget}."
  end

  def instructions
    [SYSTEM_PROMPT, itinerary_context].compact.join("\n\n")
  end
end
