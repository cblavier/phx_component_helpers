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

  @phx_attributes [
    :phx_target,
    :phx_hook,
    :phx_click,
    :phx_change,
    :phx_submit,
    :phx_disable_with
  ]

  @json_library Jason

  @doc ~S"""
  Extends assigns with html_* attributes that can be interpolated within
  your component markup.

  ## Parameters
    * `assigns` - your component assigns
    * `attributes` - a list of attributes (atoms) that will be fetched from assigns

  ## Options
    * `:init` - a list of attributes that will be initialized if absent from assigns
    * `:required` - raises if required attributes are absent from assigns
    * `:json` - when true, will JSON encode the assign value

  ## Example
  ```
  assigns
  |> set_component_attributes([:id, :name, :label], required: [:id, :name])
  |> set_component_attributes([:value], json: true)
  ```

  `assigns` now contains `@html_id`, `@html_name`, `@html_label` and `@html_value`.
  """
  def set_component_attributes(assigns, attributes, opts \\ []) do
    assigns
    |> set_attributes(attributes, &html_attribute/1, opts)
    |> set_empty_attributes(opts[:init])
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Extends assigns with html_* data-attributes that can be interpolated within
  your component markup.

  Behaves exactly like `set_component_attributes/3` excepted the output `@html_attr`
  assigns contain data-attributes markup.

  ## Example
  ```
  assigns
  |> set_data_attributes([:key, :text], required: [:key])
  |> set_data_attributes([:document], json: true)
  ```

  `assigns` now contains `@html_key`, `@html_text` and `@html_document`.
  """
  def set_data_attributes(assigns, attributes, opts \\ []) do
    assigns
    |> set_attributes(attributes, &data_attribute/1, opts)
    |> set_empty_attributes(opts[:init])
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Extends assigns with phx* attributes that can be interpolated within
  your component markup. It will automatically detect any attribute prefixed by
  `phx_` from input assigns.

  ## Parameters
    * `assigns` - your component assigns

  ## Options
    * `:init` - a list of attributes that will be initialized if absent from assigns
    * `:required` - raises if required attributes are absent from assigns

  ## Example
  ```
  assigns
  |> set_phx_attributes([:phx_change, :phx_submit], required: [:phx_submit], init: [:phx_change])
  ```

  `assigns` now contains `@html_phx_change` and `@html_phx_submit`.
  """
  def set_phx_attributes(assigns, opts \\ []) do
    assigns
    |> set_attributes(@phx_attributes, &html_attribute/1)
    |> set_empty_attributes(opts[:init])
    |> validate_required_attributes(opts[:required])
  end

  @doc ~S"""
  Extends assigns with class attributes.

  The class attribute will take provided `default_classes` as a default value and will
  be extended, on a class-by-class basis, by your assigns.

  ## Parameters
    * `assigns` - your component assigns
    * `class_attribute_name` - the class attribute you want to define, `:class` by default
    * `default_classes` - the css classed that will put by default

  ## Example
  ```
  assigns
  |> extend_class("bg-blue-500 mt-8")
  |> extend_class(:wrapper_class, "py-4 px-2 divide-y-8 divide-gray-200")
  ```

  `assigns` now contains `@html_class` and `@html_wrapper_class`.

  If your input assigns were `%{class: "mt-2", wrapper_class: "divide-none"}` then:
    * `@html_class` would contain `"bg-blue-500 mt-2"`
    * `@html_wrapper_class` would contain `"py-4 px-2 divide-none"`
  """
  def extend_class(assigns, class_attribute_name \\ :class, default_classes) do
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

    html_class = class |> Enum.join(" ") |> escaped()
    Map.put(assigns, :"html_#{class_attribute_name}", {:safe, "class=#{html_class}"})
  end

  defp set_attributes(assigns, attributes, attribute_fun, opts \\ []) do
    for attr <- attributes, reduce: assigns do
      acc ->
        html_attr = :"html_#{attr}"

        case Map.get(assigns, attr) do
          nil -> acc
          val -> Map.put(acc, html_attr, {:safe, "#{attribute_fun.(attr)}=#{escaped(val, opts)}"})
        end
    end
  end

  defp set_empty_attributes(assigns, nil), do: assigns

  defp set_empty_attributes(assigns, attributes) do
    for attr <- attributes, reduce: assigns do
      acc -> Map.put_new(acc, :"html_#{attr}", {:safe, ""})
    end
  end

  defp validate_required_attributes(assigns, nil), do: assigns

  defp validate_required_attributes(assigns, required) do
    if Enum.all?(required, &Map.has_key?(assigns, &1)) do
      assigns
    else
      raise ArgumentError, "missing required attributes"
    end
  end

  defp html_attribute(attr), do: attr |> to_string() |> String.replace("_", "-")
  defp data_attribute(attr), do: "data-#{html_attribute(attr)}"

  defp escaped(val, opts \\ [])

  defp escaped(val, json: true) do
    case Code.ensure_compiled(@json_library) do
      {:module, mod} ->
        {:safe, escaped_val} = val |> mod.encode!() |> html_escape()
        "\"#{escaped_val}\""

      _ ->
        raise ArgumentError, "#{@json_library} is not available"
    end
  end

  defp escaped(val, _) do
    {:safe, escaped_val} = html_escape(val)
    "\"#{escaped_val}\""
  end
end
