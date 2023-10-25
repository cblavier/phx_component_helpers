defmodule PhxComponentHelpers.CSS do
  @moduledoc false

  require Logger

  @doc false
  def do_css_extend_class(assigns, default_classes, class_attribute_name)
      when is_map(assigns) do
    input_class = Map.get(assigns, class_attribute_name) || ""
    do_extend_class(assigns, input_class, default_classes)
  end

  @doc false
  def do_css_extend_class(options, default_classes, class_attribute_name)
      when is_list(options) do
    input_class = Keyword.get(options, class_attribute_name) || ""
    do_extend_class(options, input_class, default_classes)
  end

  defp do_extend_class(assigns_or_options, input_class, default_classes) do
    default_classes =
      cond do
        is_function(default_classes) ->
          default_classes.(assigns_or_options)

        is_list(default_classes) ->
          default_classes
          |> List.flatten()
          |> Enum.filter(&is_binary/1)
          |> Enum.join(" ")

        true ->
          default_classes
      end

    default_classes = String.split(default_classes, [" ", "\n"], trim: true)
    extend_classes = String.split(input_class, [" ", "\n"], trim: true)
    target_classes = Enum.reject(extend_classes, &String.starts_with?(&1, "!"))

    for class <- Enum.reverse(default_classes),
        !class_should_be_removed?(class, extend_classes),
        reduce: target_classes do
      acc ->
        [class | acc]
    end
    |> Enum.join(" ")
  end

  defp class_should_be_removed?(class, extend_classes) do
    Enum.any?(extend_classes, fn
      "!" <> ^class ->
        true

      "!" <> pattern ->
        String.ends_with?(pattern, "*") and
          String.starts_with?(class, String.slice(pattern, 0..-2))

      _ ->
        false
    end)
  end
end
