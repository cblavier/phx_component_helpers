defmodule PhxComponentHelpers.Forward do
  @moduledoc false

  def handle_forward_option(assigns, {:prefix, prefix}) do
    prefix = "#{prefix}_"

    for {key, val} <- assigns, reduce: %{} do
      acc ->
        key = to_string(key)

        if String.starts_with?(key, prefix) do
          forwarded_key = key |> String.replace_leading(prefix, "") |> String.to_atom()
          Map.put(acc, forwarded_key, val)
        else
          acc
        end
    end
  end

  def handle_forward_option(assigns, {:take, attributes}) do
    Map.take(assigns, attributes)
  end

  def handle_forward_option(_assigns, {:merge, assigns}) do
    assigns
  end
end
