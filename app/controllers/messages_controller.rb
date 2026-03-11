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
      build_conversation_history # now it remembers it!
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      # @chat.messages.create(role: "assistant", content: response.content)
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
    "Here is the context of the itinerary:
    #{@itinerary.holiday_type.present? ? "a " + @itinerary.holiday_type + " holiday" : ""}
    #{@itinerary.destination.present? ? ", to destination " @itinerary.destination : ""}
    #{@itinerary.start_date.present? ? ", from " + @itinerary.start_date : ""}
    #{@itinerary.end_date.present? ? " to " + @itinerary.end_date : ""}
    #{@itinerary.adults.present? ? ", with " + @itinerary.adults + " adults" : ""}
    #{@itinerary.children.present? ? " and " + @itinerary.children + " children" : ""}
    #{@itinerary.budget.present? ? ", my buget is " + @itinerary.budget + " €" : ""}."
  end

  def instructions
    [SYSTEM_PROMPT, itinerary_context].compact.join("\n\n")
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end
end
