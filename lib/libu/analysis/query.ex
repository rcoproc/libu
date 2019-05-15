defmodule Libu.Analysis.Query do
  def get(session_id) when is_binary(session_id) do
    case :ets.lookup(:analysis_results, session_id) do
      [{_id, result}] -> {:ok, result}
      _               -> {:error, "No Analysis found"}
    end
  end
end
