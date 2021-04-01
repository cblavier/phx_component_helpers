defmodule PhxComponentHelpers.CSS do
  @moduledoc false

  @doc false
  def do_extend_class(assigns, default_classes, class_attribute_name) when is_map(assigns) do
    input_class = Map.get(assigns, class_attribute_name) || ""
    do_extend_class(input_class, default_classes)
  end

  @doc false
  def do_extend_class(options, default_classes, class_attribute_name) when is_list(options) do
    input_class = Keyword.get(options, class_attribute_name) || ""
    do_extend_class(input_class, default_classes)
  end

  defp do_extend_class(input_class, default_classes) do
    default_classes = String.split(default_classes, [" ", "\n"], trim: true)
    extend_classes = String.split(input_class, [" ", "\n"], trim: true)

    classes =
      for class <- default_classes, reduce: extend_classes do
        acc ->
          [class_prefix | _] = String.split(class, "-")

          if Enum.any?(extend_classes, &String.starts_with?(&1, "#{class_prefix}-")) do
            acc
          else
            [class | acc]
          end
      end

    Enum.join(classes, " ")
  end
end
