defmodule PhxComponentHelpers.Forward do
  @moduledoc false

  def handle_prefix_option(assigns, nil), do: assigns

  def handle_prefix_option(assigns, prefix) do
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

  def handle_take_option(assigns, nil), do: assigns

  def handle_take_option(assigns, attributes) do
    Map.take(assigns, attributes)
  end
end
