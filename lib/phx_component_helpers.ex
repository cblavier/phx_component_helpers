defmodule PhxComponentHelpers do
  @moduledoc """
  `PhxComponentHelpers` are helper functions meant to be used within Phoenix
  LiveView live_components to make your components more configurable and extensible
  from your templates.

  It provides following features:

    * set html attributes from component assigns
    * set data attributes from component assigns
    * set phx_* attributes from component assigns
    * encode attributes as JSON from an Elixir structure assign
    * validate mandatory attributes
    * set and extend css classes from component assigns
  """

  import PhxComponentHelpers.{Attributes, CSS, Forms}
  import Phoenix.HTML.Form, only: [input_id: 2, input_name: 2, input_value: 2]

  @doc ~S"""
  Extends assigns with raw_* attributes that can be interpolated within
  your component markup.

  ## Parameters
    * `assigns` - your component assigns
    * `attributes` - a list of attributes (atoms) that will be fetched from assigns

  ## Options
    * `:required` - raises if required attributes are absent from assigns
    * `:json` - when true, will JSON encode the assign value
    * `:into` - merges all assigns in a single one that can be interpolated at once

  ## Example
  ```
  assigns
  |> set_component_attributes([:id, :name, :label], required: [:id, :name], into: :attributes)
  |> set_component_attributes([:value], json: true)
  ```

  `assigns` now contains `@raw_id`, `@raw_name`, `@raw_label` and `@raw_value`.
  It also contains `@raw_attributes` which holds the values if `:id`, `:name` and `:label`.
  """
  def set_component_attributes(assigns, attributes, opts \\ []) do
    assigns
    |> set_attributes(attributes, &raw_attribute/1, opts)
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Extends assigns with raw_* data-attributes that can be interpolated within
  your component markup.

  Behaves exactly like `set_component_attributes/3` excepted the output `@raw_attr`
  assigns contain data-attributes markup.

  ## Example
  ```
  assigns
  |> set_data_attributes([:key, :text], required: [:key])
  |> set_data_attributes([:document], json: true)
  ```

  `assigns` now contains `@raw_key`, `@raw_text` and `@raw_document`.
  """
  def set_data_attributes(assigns, attributes, opts \\ []) do
    assigns
    |> set_attributes(attributes, &data_attribute/1, opts)
    |> set_empty_attributes(opts[:init])
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Extends assigns with prefixed attributes that can be interpolated within
  your component markup. It will automatically detect any attribute prefixed by
  any of the given prefixes from input assigns.

  Can be used for intance to easily map `alpinejs` html attributes.

  ## Parameters
    * `assigns` - your component assigns
    * `prefixes` - a list of prefix as binaries

  ## Options
    * `:init` - a list of attributes that will be initialized if absent from assigns
    * `:required` - raises if required attributes are absent from assigns
    * `:into` - merges all assigns in a single one that can be interpolated at once

  ## Example
  ```
  assigns
  |> set_prefixed_attributes(
      ["@click", "x-bind:"],
      required: ["x-bind:class"],
      into: :alpine_attributes
    )
  ```

  `assigns` now contains `@raw_click`, `@raw_x-bind:class` and `@raw_alpine_attributes`.
  """
  def set_prefixed_attributes(assigns, prefixes, opts \\ []) do
    phx_attributes =
      prefixes
      |> Enum.flat_map(&find_assigns_with_prefix(assigns, &1))
      |> Enum.uniq()

    assigns
    |> set_attributes(phx_attributes, &raw_attribute/1, opts)
    |> set_empty_attributes(opts[:init])
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Just a convenient method built on top of `set_prefixed_attributes/3` for phx attributes.
  It will automatically detect any attribute prefixed by `phx_` from input assigns.
  By default, the `:into` option of `set_prefixed_attributes/3` is `:phx_attributes`

  ## Example
  ```
  assigns
  |> set_phx_attributes(required: [:phx_submit], init: [:phx_change])
  ```

  `assigns` now contains `@raw_phx_change`, `@raw_phx_submit` and `@raw_phx_attributes`.
  """
  def set_phx_attributes(assigns, opts \\ []) do
    opts = Keyword.put_new(opts, :into, :phx_attributes)
    set_prefixed_attributes(assigns, ["phx_"], opts)
  end

  @doc ~S"""
  Validates that attributes are present in assigns.
  Raises an `ArgumentError` if any attribute is missing.

  ## Example
  ```
  assigns
  |> validate_required_attributes([:id, :label])
  ```
  """
  def validate_required_attributes(assigns, required)
  def validate_required_attributes(assigns, nil), do: assigns

  def validate_required_attributes(assigns, required) do
    if Enum.all?(required, &Map.has_key?(assigns, &1)) do
      assigns
    else
      raise ArgumentError, "missing required attributes"
    end
  end

  @doc ~S"""
  Extends assigns with class attributes.

  The class attribute will take provided `default_classes` as a default value and will
  be extended, on a class-by-class basis, by your assigns.

  ## Parameters
    * `assigns` - your component assigns
    * `default_classes` - the default classes that will be overridden by your assigns.

  ## Options
  * `:into` - put all css classes into this assign
  * `:error_class` - extra class that will be added if assigns contain form/field keys
  and field is faulty.

  ## Example
  ```
  assigns
  |> extend_class("bg-blue-500 mt-8")
  |> extend_class("py-4 px-2 divide-y-8 divide-gray-200", into: :wrapper_class)
  |> extend_class("form-input", error_class: "form-input-error", into: :input_class)
  ```

  `assigns` now contains `@raw_class` and `@raw_wrapper_class`.

  If your input assigns were `%{class: "mt-2", wrapper_class: "divide-none"}` then:
    * `@raw_class` would contain `"bg-blue-500 mt-2"`
    * `@raw_wrapper_class` would contain `"py-4 px-2 divide-none"`
  """
  def extend_class(assigns, default_classes, opts \\ []) do
    class_attribute_name = Keyword.get(opts, :into, :class)

    raw_class =
      assigns
      |> handle_error_class_option(opts[:error_class], class_attribute_name)
      |> do_extend_class(default_classes, class_attribute_name)
      |> escaped()

    Map.put(assigns, :"raw_#{class_attribute_name}", {:safe, "class=#{raw_class}"})
  end

  @doc ~S"""
  Extends assigns with form related attributes.

  If assigns contain `:form` and `:field` keys then it will set `:id`, `:name`, ':for',
  `:value`, and `:errors` from received `Phoenix.HTML.Form`.

  ## Parameters
    * `assigns` - your component assigns

  ## Example
  ```
  assigns
  |> set_form_attributes()
  ```
  """
  def set_form_attributes(assigns) do
    with_form_fields(
      assigns,
      fn assigns, form, field ->
        assigns
        |> put_if_new_or_nil(:id, input_id(form, field))
        |> put_if_new_or_nil(:name, input_name(form, field))
        |> put_if_new_or_nil(:for, input_name(form, field))
        |> put_if_new_or_nil(:value, input_value(form, field))
        |> put_if_new_or_nil(:errors, form_errors(form, field))
      end,
      fn assigns ->
        assigns
        |> put_if_new_or_nil(:form, nil)
        |> put_if_new_or_nil(:field, nil)
        |> put_if_new_or_nil(:id, nil)
        |> put_if_new_or_nil(:name, nil)
        |> put_if_new_or_nil(:for, nil)
        |> put_if_new_or_nil(:value, nil)
        |> put_if_new_or_nil(:errors, [])
      end
    )
  end

  defp put_if_new_or_nil(map, key, default) do
    Map.update(map, key, default, fn
      nil -> default
      val -> val
    end)
  end

  defp find_assigns_with_prefix(assigns, prefix) do
    for key <- Map.keys(assigns),
        key_s = to_string(key),
        String.starts_with?(key_s, prefix),
        do: key
  end
end
