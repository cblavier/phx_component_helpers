defmodule PhxComponentHelpers.Attributes do
  @moduledoc false
  @json_library Jason

  import Phoenix.HTML, only: [html_escape: 1]

  @doc false
  def set_attributes(assigns, attributes, attribute_fun, opts \\ []) do
    new_assigns =
      attributes
      |> Enum.reduce(%{}, fn attr, acc ->
        {attr, default} = attribute_key_and_default(attr)
        attr_key = raw_attribute_key(attr)

        case {Map.get(assigns, attr), default} do
          {nil, nil} ->
            Map.put(acc, attr_key, {:safe, ""})

          {nil, default} ->
            acc
            |> Map.put(attr, default)
            |> Map.put(attr_key, {:safe, "#{attribute_fun.(attr)}=#{escaped(default, opts)}"})

          {val, _} ->
            Map.put(acc, attr_key, {:safe, "#{attribute_fun.(attr)}=#{escaped(val, opts)}"})
        end
      end)
      |> handle_into_option(opts[:into])

    Map.merge(assigns, new_assigns)
  end

  @doc false
  def set_empty_attributes(assigns, attributes)

  def set_empty_attributes(assigns, nil), do: assigns

  def set_empty_attributes(assigns, attributes) do
    for attr <- attributes, reduce: assigns do
      acc ->
        attr_key = raw_attribute_key(attr)
        Map.put_new(acc, attr_key, {:safe, ""})
    end
  end

  @doc false
  def raw_attribute(attr), do: attr |> to_string() |> String.replace("_", "-")

  @doc false
  def data_attribute(attr), do: "data-#{raw_attribute(attr)}"

  @doc false
  def escaped(val, opts \\ [])

  def escaped(val, json: true) do
    {:safe, escaped_val} = val |> @json_library.encode!() |> html_escape()
    "\"#{escaped_val}\""
  end

  def escaped(val, _) do
    {:safe, escaped_val} = html_escape(val)
    "\"#{escaped_val}\""
  end

  defp attribute_key_and_default({attr, default}), do: {attr, default}
  defp attribute_key_and_default(attr), do: {attr, nil}

  defp raw_attribute_key(attr) do
    "raw_#{attr}" |> String.replace("@", "") |> String.to_atom()
  end

  defp handle_into_option(assigns, nil), do: assigns

  defp handle_into_option(assigns, into) do
    into_assign = for({_key, {:safe, attr}} <- assigns, do: attr)
    attr_key = raw_attribute_key(into)
    Map.put(assigns, attr_key, {:safe, Enum.join(into_assign, " ")})
  end
end
