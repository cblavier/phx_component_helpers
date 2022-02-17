defmodule PhxComponentHelpers.SetAttributes do
  @moduledoc false
  @json_library Jason

  import Phoenix.HTML, only: [html_escape: 1]

  @doc false
  def do_set_attributes(assigns, attributes, opts \\ []) do
    new_assigns =
      attributes
      |> Enum.reduce(Map.take(assigns, [:__changed__]), fn attr, acc ->
        {attr, default} = attribute_key_and_default(attr)
        raw_attr_key = raw_attribute_key(attr)
        heex_attr_key = heex_attribute_key(attr)
        raw_attribute_fun = raw_attribute_fun(opts)
        heex_attribute_fun = heex_attribute_fun(opts)

        case {Map.get(assigns, attr), default} do
          {nil, nil} ->
            acc
            |> assign(attr, nil)
            |> assign(raw_attr_key, {:safe, ""})
            |> assign(heex_attr_key, [])

          {nil, default} ->
            acc
            |> assign(attr, default)
            |> assign(
              raw_attr_key,
              {:safe, "#{raw_attribute_fun.(attr)}=#{raw_escaped(default, opts)}"}
            )
            |> assign(heex_attr_key, [{heex_attribute_fun.(attr), heex_escaped(default, opts)}])

          {val, _} ->
            acc
            |> assign(
              raw_attr_key,
              {:safe, "#{raw_attribute_fun.(attr)}=#{raw_escaped(val, opts)}"}
            )
            |> assign(heex_attr_key, [{heex_attribute_fun.(attr), heex_escaped(val, opts)}])
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
        raw_attr_key = raw_attribute_key(attr)
        heex_attr_key = heex_attribute_key(attr)

        acc
        |> Map.put_new(raw_attr_key, {:safe, ""})
        |> Map.put_new(heex_attr_key, [])
    end
  end

  defp raw_escaped(val, opts) do
    if opts[:json] do
      {:safe, escaped_val} = val |> @json_library.encode!() |> html_escape()
      "\"#{escaped_val}\""
    else
      {:safe, escaped_val} = html_escape(val)
      "\"#{escaped_val}\""
    end
  end

  defp heex_escaped(val, opts) do
    if opts[:json] do
      @json_library.encode!(val)
    else
      val
    end
  end

  defp raw_attribute_fun(opts) do
    if opts[:data] do
      &raw_data_attribute/1
    else
      &raw_attribute/1
    end
  end

  defp heex_attribute_fun(opts) do
    if opts[:data] do
      &heex_data_attribute/1
    else
      &heex_attribute/1
    end
  end

  defp raw_attribute(attr), do: attr |> to_string() |> String.replace("_", "-")
  defp raw_data_attribute(attr), do: "data-#{raw_attribute(attr)}"

  defp heex_attribute(attr),
    do: attr |> to_string() |> String.replace("_", "-") |> String.to_atom()

  defp heex_data_attribute(attr), do: String.to_atom("data-#{heex_attribute(attr)}")

  defp attribute_key_and_default({attr, default}), do: {attr, default}
  defp attribute_key_and_default(attr), do: {attr, nil}

  defp raw_attribute_key(attr) do
    "raw_#{attr}" |> String.replace("@", "") |> String.to_atom()
  end

  defp heex_attribute_key(attr) do
    "heex_#{attr}" |> String.replace("@", "") |> String.to_atom()
  end

  defp handle_into_option(assigns, nil), do: assigns

  defp handle_into_option(assigns, into) do
    raw_into_assign = for({_key, {:safe, attr}} <- assigns, do: attr)

    heex_into_assign =
      for({key, attr} <- assigns, key |> to_string() |> String.starts_with?("heex"), do: attr)
      |> List.flatten()

    raw_attr_key = raw_attribute_key(into)
    heex_attr_key = heex_attribute_key(into)

    assigns
    |> assign(raw_attr_key, {:safe, Enum.join(raw_into_assign, " ")})
    |> assign(heex_attr_key, heex_into_assign)
  end

  # support both live view assigns and mere map
  defp assign(%{__changed__: _changes} = assigns, key, value),
    do: Phoenix.LiveView.assign(assigns, key, value)

  defp assign(assigns, key, value), do: Map.put(assigns, key, value)
end
