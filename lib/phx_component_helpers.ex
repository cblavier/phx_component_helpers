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

  import Phoenix.HTML, only: [html_escape: 1]

  @json_library Jason

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
  Just a convenient method built on top of `set_prefixed_attributes/3` for phx_* attributes.
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

  ## Example
  ```
  assigns
  |> extend_class("bg-blue-500 mt-8")
  |> extend_class("py-4 px-2 divide-y-8 divide-gray-200", into: :wrapper_class)
  ```

  `assigns` now contains `@raw_class` and `@raw_wrapper_class`.

  If your input assigns were `%{class: "mt-2", wrapper_class: "divide-none"}` then:
    * `@raw_class` would contain `"bg-blue-500 mt-2"`
    * `@raw_wrapper_class` would contain `"py-4 px-2 divide-none"`
  """
  def extend_class(assigns, default_classes, opts \\ []) do
    class_attribute_name = Keyword.get(opts, :into, :class)
    default_classes = String.split(default_classes, [" ", "\n"], trim: true)
    assigns_class = Map.get(assigns, class_attribute_name, "")
    extend_classes = String.split(assigns_class, [" ", "\n"], trim: true)

    class =
      for class <- default_classes, reduce: extend_classes do
        acc ->
          [class_prefix | _] = String.split(class, "-")

          if Enum.any?(extend_classes, &String.starts_with?(&1, "#{class_prefix}-")) do
            acc
          else
            [class | acc]
          end
      end

    raw_class = class |> Enum.join(" ") |> escaped()
    Map.put(assigns, :"raw_#{class_attribute_name}", {:safe, "class=#{raw_class}"})
  end

  defp set_attributes(assigns, attributes, attribute_fun, opts) do
    new_assigns =
      attributes
      |> Enum.reduce(%{}, fn attr, acc ->
        attr_key = raw_attribute_key(attr)

        case Map.get(assigns, attr) do
          nil -> Map.put(acc, attr_key, {:safe, ""})
          val -> Map.put(acc, attr_key, {:safe, "#{attribute_fun.(attr)}=#{escaped(val, opts)}"})
        end
      end)
      |> handle_into_option(opts[:into])

    Map.merge(assigns, new_assigns)
  end

  defp handle_into_option(assigns, nil), do: assigns

  defp handle_into_option(assigns, into) do
    into_assign = for({_key, {:safe, attr}} <- assigns, do: attr)
    attr_key = raw_attribute_key(into)
    Map.put(assigns, attr_key, {:safe, Enum.join(into_assign, " ")})
  end

  defp set_empty_attributes(assigns, nil), do: assigns

  defp set_empty_attributes(assigns, attributes) do
    for attr <- attributes, reduce: assigns do
      acc ->
        attr_key = raw_attribute_key(attr)
        Map.put_new(acc, attr_key, {:safe, ""})
    end
  end

  defp raw_attribute(attr), do: attr |> to_string() |> String.replace("_", "-")
  defp data_attribute(attr), do: "data-#{raw_attribute(attr)}"

  defp raw_attribute_key(attr) do
    "raw_#{attr}" |> String.replace("@", "") |> String.to_atom()
  end

  defp escaped(val, opts \\ [])

  defp escaped(val, json: true) do
    {:safe, escaped_val} = val |> @json_library.encode!() |> html_escape()
    "\"#{escaped_val}\""
  end

  defp escaped(val, _) do
    {:safe, escaped_val} = html_escape(val)
    "\"#{escaped_val}\""
  end

  defp find_assigns_with_prefix(assigns, prefix) do
    for key <- Map.keys(assigns),
        key_s = to_string(key),
        String.starts_with?(key_s, prefix),
        do: key
  end
end
