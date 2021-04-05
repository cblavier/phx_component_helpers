defmodule PhxComponentHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias PhxComponentHelpers, as: Helpers

  alias Phoenix.HTML.Form

  describe "set_component_attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with known attributes it sets the raw attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo])
      assert new_assigns == Map.put(assigns, :raw_foo, {:safe, "foo=\"foo\""})
    end

    test "absent assigns are set as empty attributes" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:baz])
      assert new_assigns == Map.put(assigns, :raw_baz, {:safe, ""})
    end

    test "with known attributes and json opt, it sets the attribute as json" do
      assigns = %{foo: %{here: "some json"}, bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo], json: true)

      assert new_assigns ==
               Map.put(
                 assigns,
                 :raw_foo,
                 {:safe, "foo=\"{&quot;here&quot;:&quot;some json&quot;}\""}
               )
    end

    test "validates required attributes" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [], required: [:foo])
      assert new_assigns == assigns
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_component_attributes(assigns, [], required: [:baz])
      end
    end

    test "with into option, it merges all in a single assign" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo, :bar], into: :attributes)

      assert new_assigns ==
               assigns
               |> Map.put(:raw_foo, {:safe, "foo=\"foo\""})
               |> Map.put(:raw_bar, {:safe, "bar=\"bar\""})
               |> Map.put(:raw_attributes, {:safe, "bar=\"bar\" foo=\"foo\""})
    end

    test "set default values" do
      assigns = %{foo: "foo"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo, bar: "bar"])

      assert new_assigns ==
               assigns
               |> Map.put(:raw_foo, {:safe, "foo=\"foo\""})
               |> Map.put(:raw_bar, {:safe, "bar=\"bar\""})
    end

    test "set default json values" do
      assigns = %{foo: %{here: "some json"}}

      new_assigns =
        Helpers.set_component_attributes(assigns, [:foo, bar: %{there: "also json"}], json: true)

      assert new_assigns ==
               assigns
               |> Map.put(
                 :raw_foo,
                 {:safe, "foo=\"{&quot;here&quot;:&quot;some json&quot;}\""}
               )
               |> Map.put(
                 :raw_bar,
                 {:safe, "bar=\"{&quot;there&quot;:&quot;also json&quot;}\""}
               )
    end
  end

  describe "set_data_attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with known attributes it sets the raw attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [:foo])
      assert new_assigns == Map.put(assigns, :raw_foo, {:safe, "data-foo=\"foo\""})
    end

    test "with known attributes and json opt, it sets the attribute as json" do
      assigns = %{foo: %{here: "some json"}, bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [:foo], json: true)

      assert new_assigns ==
               Map.put(
                 assigns,
                 :raw_foo,
                 {:safe, "data-foo=\"{&quot;here&quot;:&quot;some json&quot;}\""}
               )
    end

    test "with init attributes it adds empty attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [], init: [:baz])
      assert new_assigns == Map.put(assigns, :raw_baz, {:safe, ""})
    end

    test "validates required attributes" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [], required: [:foo])
      assert new_assigns == assigns
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_data_attributes(assigns, [], required: [:baz])
      end
    end

    test "set default values" do
      assigns = %{foo: "foo"}
      new_assigns = Helpers.set_data_attributes(assigns, [:foo, bar: "bar"])

      assert new_assigns ==
               assigns
               |> Map.put(:raw_foo, {:safe, "data-foo=\"foo\""})
               |> Map.put(:raw_bar, {:safe, "data-bar=\"bar\""})
    end

    test "set default json values" do
      assigns = %{foo: %{here: "some json"}}

      new_assigns =
        Helpers.set_data_attributes(assigns, [:foo, bar: %{there: "also json"}], json: true)

      assert new_assigns ==
               assigns
               |> Map.put(
                 :raw_foo,
                 {:safe, "data-foo=\"{&quot;here&quot;:&quot;some json&quot;}\""}
               )
               |> Map.put(
                 :raw_bar,
                 {:safe, "data-bar=\"{&quot;there&quot;:&quot;also json&quot;}\""}
               )
    end
  end

  describe "set_prefixed_attributes" do
    test "without phx assigns it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with alpinejs assigns it adds the raw attributes" do
      assigns = %{"@click" => "open = true", "x-bind:class" => "open", foo: "foo"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"])

      assert new_assigns ==
               assigns
               |> Map.put(:raw_click, {:safe, "@click=\"open = true\""})
               |> Map.put(:"raw_x-bind:class", {:safe, "x-bind:class=\"open\""})
    end

    test "with init attributes it adds empty attribute" do
      assigns = %{foo: "foo", bar: "bar"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], init: ["@click.away"])

      assert new_assigns == assigns |> Map.put(:"raw_click.away", {:safe, ""})
    end

    test "validates required attributes" do
      assigns = %{"@click.away" => "open = false"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])

      assert new_assigns ==
               assigns
               |> Map.put(:"raw_click.away", {:safe, "@click.away=\"open = false\""})
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])
      end
    end
  end

  describe "set_phx_attributes" do
    test "with phx assigns it adds the phx-attribute" do
      assigns = %{phx_change: "foo", phx_click: "bar", baz: "baz"}
      new_assigns = Helpers.set_phx_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:raw_phx_change, {:safe, "phx-change=\"foo\""})
               |> Map.put(:raw_phx_click, {:safe, "phx-click=\"bar\""})
               |> Map.put(:raw_phx_attributes, {:safe, "phx-change=\"foo\" phx-click=\"bar\""})
    end

    test "with init attributes it adds empty attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_phx_attributes(assigns, init: [:phx_submit], into: nil)
      assert new_assigns == Map.put(assigns, :raw_phx_submit, {:safe, ""})
    end

    test "validates required attributes" do
      assigns = %{phx_click: "click"}
      new_assigns = Helpers.set_phx_attributes(assigns, required: [:phx_click], into: nil)
      assert new_assigns == Map.put(assigns, :raw_phx_click, {:safe, "phx-click=\"click\""})
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_phx_attributes(assigns, required: [:phx_click])
      end
    end
  end

  describe "validate_required_attributes" do
    test "validates required attributes" do
      assigns = %{phx_click: "click"}
      new_assigns = Helpers.validate_required_attributes(assigns, [:phx_click])
      assert new_assigns == assigns
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.validate_required_attributes(assigns, [:phx_click])
      end
    end
  end

  describe "extend_class" do
    test "without class keeps the default class attribute" do
      assigns = %{c: "foo", bar: "bar"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8")
      assert new_assigns == Map.put(assigns, :raw_class, {:safe, "class=\"mt-8 bg-blue-500\""})
    end

    test "with class extends the default class attribute" do
      assigns = %{class: "mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8 ")
      assert new_assigns == Map.put(assigns, :raw_class, {:safe, "class=\"bg-blue-500 mt-2\""})
    end

    test "can extend other class attribute" do
      assigns = %{wrapper_class: "mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8 ", attribute: :wrapper_class)

      assert new_assigns ==
               Map.put(assigns, :raw_wrapper_class, {:safe, "class=\"bg-blue-500 mt-2\""})
    end

    test "extends with error_class when a form field is faulty" do
      assigns = %{
        class: "mt-2",
        form: %Form{data: %{my_field: "42"}, errors: [my_field: "error"]},
        field: :my_field
      }

      new_assigns =
        Helpers.extend_class(assigns, "bg-blue-500 mt-8", error_class: "form-input-error")

      assert new_assigns ==
               Map.put(
                 assigns,
                 :raw_class,
                 {:safe, "class=\"bg-blue-500 mt-2 form-input-error\""}
               )
    end

    test "does not extend with error_class when a form field is not faulty" do
      assigns = %{
        class: "mt-2",
        form: %Form{data: %{my_field: "42"}, source: %{errors: []}},
        field: :my_field
      }

      new_assigns =
        Helpers.extend_class(assigns, "bg-blue-500 mt-8", error_class: "form-input-error")

      assert new_assigns ==
               Map.put(
                 assigns,
                 :raw_class,
                 {:safe, "class=\"bg-blue-500 mt-2\""}
               )
    end
  end

  describe "set_form_attributes" do
    test "without form keeps the input assigns" do
      assigns = %{c: "foo", bar: "bar"}
      new_assigns = Helpers.set_form_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:form, nil)
               |> Map.put(:field, nil)
               |> Map.put(:for, nil)
               |> Map.put(:id, nil)
               |> Map.put(:name, nil)
               |> Map.put(:value, nil)
               |> Map.put(:errors, [])
    end

    test "with form, field and value, set the form assigns" do
      assigns = %{
        c: "foo",
        form: %Form{data: %{my_field: "42"}},
        field: :my_field
      }

      new_assigns = Helpers.set_form_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:for, "my_field")
               |> Map.put(:id, "my_field")
               |> Map.put(:name, "my_field")
               |> Map.put(:value, "42")
               |> Map.put(:errors, [])
    end

    test "with form, field and without value, set the form assigns" do
      assigns = %{
        c: "foo",
        form: %Form{data: %{}},
        field: :my_field
      }

      new_assigns = Helpers.set_form_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:for, "my_field")
               |> Map.put(:id, "my_field")
               |> Map.put(:name, "my_field")
               |> Map.put(:value, nil)
               |> Map.put(:errors, [])
    end

    test "with form, does not overwrite set values, but overwrite nil values" do
      assigns = %{
        c: "foo",
        for: "already_set",
        id: nil,
        form: %Form{data: %{}},
        field: :my_field
      }

      new_assigns = Helpers.set_form_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:id, "my_field")
               |> Map.put(:name, "my_field")
               |> Map.put(:value, nil)
               |> Map.put(:errors, [])
    end
  end
end
