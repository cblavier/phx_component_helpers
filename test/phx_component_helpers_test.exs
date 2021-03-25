defmodule PhxComponentHelpersTest do
  use ExUnit.Case, async: true
  alias PhxComponentHelpers, as: Helpers

  describe "set_component_attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with known attributes it sets the raw html attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo])
      assert new_assigns == Map.put(assigns, :html_foo, {:safe, "foo=\"foo\""})
    end

    test "absent assigns are set as empty html attributes" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:baz])
      assert new_assigns == Map.put(assigns, :html_baz, {:safe, ""})
    end

    test "with known attributes and json opt, it sets the attribute as json" do
      assigns = %{foo: %{here: "some json"}, bar: "bar"}
      new_assigns = Helpers.set_component_attributes(assigns, [:foo], json: true)

      assert new_assigns ==
               Map.put(
                 assigns,
                 :html_foo,
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
  end

  describe "set_data_attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with known attributes it sets the raw html attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [:foo])
      assert new_assigns == Map.put(assigns, :html_foo, {:safe, "data-foo=\"foo\""})
    end

    test "with known attributes and json opt, it sets the attribute as json" do
      assigns = %{foo: %{here: "some json"}, bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [:foo], json: true)

      assert new_assigns ==
               Map.put(
                 assigns,
                 :html_foo,
                 {:safe, "data-foo=\"{&quot;here&quot;:&quot;some json&quot;}\""}
               )
    end

    test "with init attributes it adds empty html attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_data_attributes(assigns, [], init: [:baz])
      assert new_assigns == Map.put(assigns, :html_baz, {:safe, ""})
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
  end

  describe "set_prefixed_attributes" do
    test "without phx assigns it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with alpinejs assigns it adds the html phx-attribute" do
      assigns = %{"@click" => "open = true", "x-bind:class" => "open", foo: "foo"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"])

      assert new_assigns ==
               assigns
               |> Map.put(:html_click, {:safe, "@click=\"open = true\""})
               |> Map.put(:"html_x-bind:class", {:safe, "x-bind:class=\"open\""})
    end

    test "with init attributes it adds empty html attribute" do
      assigns = %{foo: "foo", bar: "bar"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], init: ["@click.away"])

      assert new_assigns == assigns |> Map.put(:"html_click.away", {:safe, ""})
    end

    test "validates required attributes" do
      assigns = %{"@click.away" => "open = false"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])

      assert new_assigns ==
               assigns
               |> Map.put(:"html_click.away", {:safe, "@click.away=\"open = false\""})
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])
      end
    end
  end

  describe "set_phx_attributes" do
    test "with phx assigns it adds the html phx-attribute" do
      assigns = %{phx_change: "foo", bar: "bar"}
      new_assigns = Helpers.set_phx_attributes(assigns)
      assert new_assigns == Map.put(assigns, :html_phx_change, {:safe, "phx-change=\"foo\""})
    end

    test "with init attributes it adds empty html attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_phx_attributes(assigns, init: [:phx_submit])
      assert new_assigns == Map.put(assigns, :html_phx_submit, {:safe, ""})
    end

    test "validates required attributes" do
      assigns = %{phx_click: "click"}
      new_assigns = Helpers.set_phx_attributes(assigns, required: [:phx_click])
      assert new_assigns == Map.put(assigns, :html_phx_click, {:safe, "phx-click=\"click\""})
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_phx_attributes(assigns, required: [:phx_click])
      end
    end
  end

  describe "extend_class" do
    test "without class keeps the default class attribute" do
      assigns = %{c: "foo", bar: "bar"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8")
      assert new_assigns == Map.put(assigns, :html_class, {:safe, "class=\"mt-8 bg-blue-500\""})
    end

    test "with class extends the default class attribute" do
      assigns = %{class: "mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8 ")
      assert new_assigns == Map.put(assigns, :html_class, {:safe, "class=\"bg-blue-500 mt-2\""})
    end

    test "can extend other class attribute" do
      assigns = %{wrapper_class: "mt-2"}
      new_assigns = Helpers.extend_class(assigns, :wrapper_class, "bg-blue-500 mt-8 ")

      assert new_assigns ==
               Map.put(assigns, :html_wrapper_class, {:safe, "class=\"bg-blue-500 mt-2\""})
    end
  end
end
