defmodule Libu.Chat do
  @moduledoc """
  Users can publish messages to conversations.

  The first published message also starts a conversation.

  This conversation is a process. Conversations last only 30 minutes after their last message to their context.

  Anyone else can reply to the conversation linking their message to the parent.

  Others can link their message to one or many other messages.

  Context, the linking mechanism, is part of every message except the root message of which it defaults to a root context.

  Any message that is referenced as context spawns another process initiating another conversation process.

  Each conversation is supervised by a pool of Dynamic Supervisors.

  This is mostly an excuse to play with the Registry and Dynamic Supervisors.

  We might store state only transiently within ETS.

  We could also persist streams of converations into an event store.
  """
  alias Libu.Chat.{
    Events.ConversationStarted,
    Events.MessagePublished,
    Message,
    Conversation,
  }

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Libu.PubSub, @topic)
  end

  def subscribe(conversation_id) do
    Phoenix.PubSub.subscribe(Libu.PubSub, @topic <> "#{conversation_id}")
  end

  # def publish_message(params, [form: true]), do: PublishMessage.new(params, form: true)
  # def publish_message(params \\ %{}) do
  #   with {:ok, command} <- PublishMessage.new(params) do
  #     command
  #     |> PublishMessage.
  #   end
  # end
  def publish_message(message_attrs, conversation_id) do
    with {:ok, message} <- Message.new(message_attrs) do

    end
    # Find Conversation
    # Deliver message to conversation process
  end

  @doc """
  Creates a new conversation of which other users can reply to.
  """
  def initiate_conversation(message_attrs) do
    with {:ok, message}      <- Message.new(message_attrs),
         {:ok, conversation} <- Conversation.start(message)
    do
      conversation
      |> ConversationStarted.new()
      |> notify_subscribers()

      {:ok, conversation}
    end
  end

  defp notify_subscribers(event) do
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic, {__MODULE__, event})
    Phoenix.PubSub.broadcast(Libu.PubSub, @topic <> "#{event.conversation_id}", {__MODULE__, event})
    {:ok, event}
  end

end
