defmodule PhxComponentHelpers.SetAttributes do
  @moduledoc false
  @json_library Jason

  @doc false
  def do_set_attributes(assigns, attributes, opts \\ []) do
    new_assigns =
      attributes
      |> Enum.reduce(Map.take(assigns, [:__changed__]), fn attr, acc ->
        {attr, default} = attribute_key_and_default(attr)
        heex_attr_key = heex_attribute_key(attr)
        heex_attribute_fun = heex_attribute_fun(opts)

        case {Map.get(assigns, attr), default} do
          {nil, nil} ->
            acc
            |> assign(attr, nil)
            |> assign(heex_attr_key, [])

          {nil, default} ->
            acc
            |> assign(attr, default)
            |> assign(heex_attr_key, [{heex_attribute_fun.(attr), heex_escaped(default, opts)}])

          {val, _} ->
            assign(acc, heex_attr_key, [{heex_attribute_fun.(attr), heex_escaped(val, opts)}])
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
        heex_attr_key = heex_attribute_key(attr)
        assign_new(acc, heex_attr_key, fn -> [] end)
    end
  end

  # support both live view assigns and mere map
  def assign(%{__changed__: _changes} = assigns, key, value),
    do: Phoenix.Component.assign(assigns, key, value)

  def assign(assigns, key, value), do: Map.put(assigns, key, value)

  def assign(%{__changed__: _changes} = assigns, keyword_or_map),
    do: Phoenix.Component.assign(assigns, keyword_or_map)

  def assign(assigns, keyword_or_map), do: Map.merge(assigns, keyword_or_map)

  def assign_new(%{__changed__: _changes} = assigns, key, fun),
    do: Phoenix.Component.assign_new(assigns, key, fun)

  def assign_new(assigns, key, fun), do: Map.put_new_lazy(assigns, key, fun)

  defp heex_escaped(val, opts) do
    if opts[:json] do
      @json_library.encode!(val)
    else
      val
    end
  end

  defp heex_attribute_fun(opts) do
    if opts[:data] do
      &heex_data_attribute/1
    else
      &heex_attribute/1
    end
  end

  defp heex_attribute(attr),
    do: attr |> to_string() |> String.replace("_", "-") |> String.to_atom()

  defp heex_data_attribute(attr), do: String.to_atom("data-#{heex_attribute(attr)}")

  defp attribute_key_and_default({attr, default}), do: {attr, default}
  defp attribute_key_and_default(attr), do: {attr, nil}

  defp heex_attribute_key(attr) do
    "heex_#{attr}" |> String.replace("@", "") |> String.to_atom()
  end

  defp handle_into_option(assigns, nil), do: assigns

  defp handle_into_option(assigns, into) do
    heex_into_assign =
      for({key, attr} <- assigns, key |> to_string() |> String.starts_with?("heex"), do: attr)
      |> List.flatten()

    heex_attr_key = heex_attribute_key(into)
    assign(assigns, heex_attr_key, heex_into_assign)
  end
end
