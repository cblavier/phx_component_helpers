defmodule PhxViewHelpers do
  @moduledoc """
   `PhxComponentHelpers` are helper functions meant to be used within Phoenix your views to
   facilitate usage of live_components inside templates.
  """

  import PhxComponentHelpers.CSS

  @doc ~S"""
  Extends `Phoenix.Component.form/1` options to merge css class as with
  `PhxComponentHelpers.extend_class/2`.

  It's useful to define your own `my_form` function with default css classes that still can be
  overriden from the template.

  ## Example
  ```
  def my_form(options) do
    new_options = extend_form_class(options, "mt-4 space-y-2")
    Component.form(new_options)
  end
  ```
  """
  def extend_form_class(options, default_classes) when is_list(options) do
    extended_classes = do_css_extend_class(options, default_classes, :class)
    Keyword.put(options, :class, extended_classes)
  end

  def extend_form_class(options, default_classes) when is_map(options) do
    extended_classes = do_css_extend_class(options, default_classes, :class)
    Map.put(options, :class, extended_classes)
  end
end
