defmodule PhxComponentHelpers.Forms do
  @moduledoc false

  @doc false
  def handle_error_class_option(assigns, nil, _class_attribute_name), do: assigns

  def handle_error_class_option(assigns, error_class, class_attribute_name) do
    with_form_fields(assigns, fn assigns, form, field ->
      if errors?(form, field) do
        input_class = Map.get(assigns, class_attribute_name) || ""
        new_class = String.trim(input_class <> " " <> error_class)
        Map.put(assigns, class_attribute_name, new_class)
      else
        assigns
      end
    end)
  end

  @doc false
  def with_form_fields(assigns, fun, fallback \\ & &1) do
    form = assigns[:form]
    field = assigns[:field]

    if form && field do
      fun.(assigns, form, field)
    else
      fallback.(assigns)
    end
  end

  @doc false
  def form_errors(form, field) do
    Keyword.get_values(form.errors, field)
  end

  defp errors?(form, field) do
    errors = Keyword.get_values(form.errors, field)
    errors && !Enum.empty?(errors)
  end
end
