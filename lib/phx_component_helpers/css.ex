defmodule PhxComponentHelpers.CSS do
  @moduledoc false

  require Logger

  @doc false
  def do_css_extend_class(assigns, default_classes, class_attribute_name, prefix_replace \\ false)

  @doc false
  def do_css_extend_class(assigns, default_classes, class_attribute_name, prefix_replace)
      when is_map(assigns) do
    input_class = Map.get(assigns, class_attribute_name) || ""
    do_extend_class(assigns, input_class, default_classes, prefix_replace)
  end

  @doc false
  def do_css_extend_class(options, default_classes, class_attribute_name, prefix_replace)
      when is_list(options) do
    input_class = Keyword.get(options, class_attribute_name) || ""
    do_extend_class(options, input_class, default_classes, prefix_replace)
  end

  @doc false
  def warn_for_deprecated_prefix_replace(false), do: :ok

  @doc false
  def warn_for_deprecated_prefix_replace(true) do
    Logger.warn("""
    Prefix based class replacement in extend_class/3 will soon be deprecated.
    Use prefix_replace: false to disable this behavior and suppress this warning message.
    """)
  end

  defp do_extend_class(assigns_or_options, input_class, default_classes, prefix_replace) do
    default_classes =
      if is_function(default_classes),
        do: default_classes.(assigns_or_options),
        else: default_classes

    default_classes = String.split(default_classes, [" ", "\n"], trim: true)
    extend_classes = String.split(input_class, [" ", "\n"], trim: true)
    target_classes = Enum.reject(extend_classes, &String.starts_with?(&1, "!"))

    for class <- Enum.reverse(default_classes),
        !class_should_be_removed?(class, extend_classes, prefix_replace),
        reduce: target_classes do
      acc ->
        [class | acc]
    end
    |> Enum.join(" ")
  end

  defp class_should_be_removed?(class, extend_classes, prefix_replace) do
    Enum.any?(extend_classes, fn
      "!" <> ^class ->
        true

      "!" <> pattern ->
        String.ends_with?(pattern, "*") and
          String.starts_with?(class, String.slice(pattern, 0..-2))

      extend_class when prefix_replace ->
        [class_prefix | _] = String.split(class, "-")
        String.starts_with?(extend_class, "#{class_prefix}-")

      _ ->
        false
    end)
  end
end
