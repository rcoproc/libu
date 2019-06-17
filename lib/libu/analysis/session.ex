defmodule Libu.Analysis.Session do
  @moduledoc """
  Represents the state of a 1:1 LiveView session.
  """
  alias Libu.Analysis.{
    Sentiment,
    Text,
    Editing,
    Events.TextChanged,
  }

  defstruct id: nil,
            text: "",
            version: 0,
            analyzers: [],
            start: nil,
            last_edited_on: nil

  defp analyzer_defaults, do: [
    Sentiment,
    Text,
    Editing,
  ]

  def new(session_id) do
    struct(__MODULE__, [
      id: session_id,
      start: DateTime.utc_now(),
      analyzers: analyzer_defaults(),
    ])
  end

  def set_text(%__MODULE__{version: version} = session, text)
  when is_binary(text) do
    %__MODULE__{session |
      version: version + 1,
      text: text,
      last_edited_on: DateTime.utc_now(),
    }
  end

  def configure_analyzers(%__MODULE__{} = session, new_analyzers)
  when is_list(new_analyzers) do
    %__MODULE__{session | analyzers: new_analyzers}
  end
end
