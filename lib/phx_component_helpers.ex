defmodule PhxComponentHelpers do
  @moduledoc """
  `PhxComponentHelpers` are helper functions meant to be used within Phoenix
  LiveView live_components to make your components more configurable and extensible
  from your templates.

  It provides following features:

  * set HTML or data attributes from component assigns
  * set phx-* attributes from component assigns
  * set attributes with any custom prefix such as `@click` or `x-bind:` from [alpinejs](https://github.com/alpinejs/alpine)
  * encode attributes as JSON from an Elixir structure assign
  * validate mandatory attributes
  * set and extend CSS classes from component assigns
  """

  import PhxComponentHelpers.{SetAttributes, CSS, Forms, Forward}
  import Phoenix.HTML.Form, only: [input_id: 2, input_name: 2, input_value: 2]

  @doc ~S"""
  Extends assigns with heex_* attributes that can be interpolated within
  your component markup.

  ## Parameters
    * `assigns` - your component assigns
    * `attributes` - a list of attributes (atoms) that will be fetched from assigns.
    Attributes can either be single atoms or tuples in the form `{:atom, default}` to
    provide default values.

  ## Options
  * `:required` - raises if required attributes are absent from assigns
  * `:json` - when true, will JSON encode the assign value
  * `:data` - when true, HTML attributes are prefixed with `data-`
  * `:into` - merges all assigns in a single one that can be interpolated at once

  ## Example
  ```
  assigns
  |> set_attributes(
      [:id, :name, label: "default label"],
      required: [:id, :name],
      into: :attributes
    )
  |> set_attributes([:value], json: true)
  ```

  `assigns` now contains :
  - `@heex_id`, `@heex_name`, `@heex_label` and `@heex_value`.
  - `@heex_attributes` which holds the values if `:id`, `:name` and `:label`.
  """
  def set_attributes(assigns, attributes, opts \\ []) do
    assigns
    |> do_set_attributes(attributes, opts)
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

  `assigns` now contains `@heex_click`, `@heex_x-bind:class`
  and `@heex_alpine_attributes`.
  """
  def set_prefixed_attributes(assigns, prefixes, opts \\ []) do
    phx_attributes =
      prefixes
      |> Enum.flat_map(&find_assigns_with_prefix(assigns, &1))
      |> Enum.uniq()

    assigns
    |> do_set_attributes(phx_attributes, opts)
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
  |> set_phx_attributes(required: [:"phx-submit"], init: [:"phx-change"])
  ```

  `assigns` now contains `@heex_phx_change`, `@heex_phx_submit`
  and `@heex_phx_attributes`.
  """
  def set_phx_attributes(assigns, opts \\ []) do
    opts = Keyword.put_new(opts, :into, :phx_attributes)
    set_prefixed_attributes(assigns, ["phx-"], opts)
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
    missing = for attr <- required, !Map.has_key?(assigns, attr), do: attr

    if Enum.any?(missing) do
      raise ArgumentError, "missing required attributes #{inspect(missing)}"
    else
      assigns
    end
  end

  @doc ~S"""
  Set assigns with class attributes.

  The class attribute will take provided `default_classes` as a default value and will
  be extended, on a class-by-class basis, by your assigns.

  This function will identify default classes to be replaced by assigns on a prefix basis:
  - "bg-gray-200" will be overwritten by "bg-blue-500" because they share the same "bg-" prefix
  - "hover:bg-gray-200" will be overwritten by "hover:bg-blue-500" because they share the same
  "hover:bg-" prefix
  - "m-1" would not be overwritten by "mt-1" because they don't share the same prefix ("m-" vs "mt-")

  ## Parameters
  * `assigns` - your component assigns
  * `default_classes` - the default classes that will be overridden by your assigns.
  This parameter can be a binary or a single parameter function that receives all assigns and
  returns a binary

  ## Options
  * `:attribute` - read & write css classes from & into this key

  ## Example
  ```
  assigns
  |> extend_class("bg-blue-500 mt-8")
  |> extend_class("py-4 px-2 divide-y-8 divide-gray-200", attribute: :wrapper_class)
  |> extend_class(fn assigns ->
      default = "p-2 m-4 text-sm "
      if assigns[:active], do: default <> "bg-indigo-500", else: default <> "bg-gray-200"
     end)
  ```

  `assigns` now contains `@heex_class` and `@heex_wrapper_class`.

  If your input assigns were `%{class: "mt-2", wrapper_class: "divide-none"}` then:
  * `@heex_class` would contain `"bg-blue-500 mt-2"`
  * `@heex_wrapper_class` would contain `"py-4 px-2 divide-none"`
  """
  def extend_class(assigns, default_classes, opts \\ []) do
    class_attribute_name = Keyword.get(opts, :attribute, :class)

    new_class = do_css_extend_class(assigns, default_classes, class_attribute_name)

    assigns
    |> Map.put(:"#{class_attribute_name}", new_class)
    |> Map.put(:"heex_#{class_attribute_name}", class: new_class)
  end

  @doc ~S"""
  Extends assigns with form related attributes.

  If assigns contain `:form` and `:field` keys then it will set `:id`, `:name`, `:for`,
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

  @doc ~S"""
  Forward and filter assigns to sub components.
  By default it doesn't forward anything unless you provide it with any combination
  of the options described below.

  ## Parameters
  * `assigns` - your component assigns

  ## Options
  * `prefix` - will only forward assigns prefixed by the given prefix. Forwarded assign key will no longer have the prefix
  * `take`- is a list of key (without prefix) that will be picked from assigns to be forwarded
  * `merge`- takes a map that will be merged as-is to the output assigns

  If both options are given at the same time, the resulting assigns will be the union of the two.


  ## Example
  Following will forward an assign map containing `%{button_id: 42, button_label: "label", phx_click: "save"}` as `%{id: 42, label: "label", phx_click: "save"}`
  ```
  forward_assigns(assigns, prefix: :button, take: [:phx_click])
  ```
  """
  def forward_assigns(assigns, opts) do
    for option <- opts, reduce: %{} do
      acc ->
        assigns = handle_forward_option(assigns, option)
        Map.merge(acc, assigns)
    end
  end

  @doc ~S"""
  If assigns include form and field entries, this function will let you
  know if the given field is in error or not.
  Returns true or false.

  ## Parameters
  * `assigns` - your component assigns, which should have `form` and `field` keys.
  """
  def has_errors?(_assigns = %{form: form, field: field})
      when not is_nil(form) and not is_nil(field) do
    errors = form_errors(form, field)
    errors && !Enum.empty?(errors)
  end

  def has_errors?(_assigns), do: false

  defp put_if_new_or_nil(map, key, val) do
    Map.update(map, key, val, fn
      nil -> val
      current -> current
    end)
  end

  defp find_assigns_with_prefix(assigns, prefix) do
    for key <- Map.keys(assigns),
        key_s = to_string(key),
        String.starts_with?(key_s, prefix),
        do: key
  end
end
