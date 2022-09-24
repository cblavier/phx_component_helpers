defmodule PhxComponentHelpers.Forms do
  @moduledoc false

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
  def form_errors(form, field) when not is_nil(form) and not is_nil(field) do
    case form.errors do
      nil -> []
      errors -> Keyword.get_values(errors, field)
    end
  end
end
