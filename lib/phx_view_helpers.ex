defmodule PhxViewHelpers do
  @moduledoc """
   `PhxComponentHelpers` are helper functions meant to be used within Phoenix
  your views to facilitate usage of live_components inside templates.
  """

  import PhxComponentHelpers.CSS

  @doc ~S"""
  Extends `Phoenix.HTML.Form.form_for/3` options to merge css class as with
  `PhxComponentHelpers.extend_class/2`.

  It's useful to define your own `form_for` functions with default css classes
  that still can be overriden from the template.

  ## Example
  ```
  def my_form_for(form_data, action, options) when is_list(options) do
    new_options = extend_form_class(options, "mt-4 space-y-2")
    form_for(form_data, action, new_options)
  end
  """
  def extend_form_class(options, default_classes) do
    extended_classes = do_css_extend_class(options, default_classes, :class)
    Keyword.put(options, :class, extended_classes)
  end
end
