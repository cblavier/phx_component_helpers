defmodule PhxComponentHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias PhxComponentHelpers, as: Helpers
  alias Phoenix.HTML.Form

  defp assigns(input), do: Map.merge(input, %{__changed__: %{}})

  describe "set_attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = assigns(%{foo: "foo", bar: "bar"})
      new_assigns = Helpers.set_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with known attributes it set the heex attributes" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      assert %{heex_foo: [foo: "foo"]} = Helpers.set_attributes(assigns, [:foo])
    end

    test "with liveview assigns" do
      assigns = assigns(%{__changed__: [], foo: "foo", bar: "bar"})

      assert %{heex_foo: [foo: "foo"]} = Helpers.set_attributes(assigns, [:foo])
    end

    test "absent assigns are set as empty attributes" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      assert %{baz: nil, heex_baz: []} = Helpers.set_attributes(assigns, [:baz])
    end

    test "with known attributes and json opt, it set the attribute as json" do
      assigns = assigns(%{foo: %{here: "some json"}, bar: "bar"})
      new_assigns = Helpers.set_attributes(assigns, [:foo], json: true)
      assert new_assigns[:heex_foo] == [foo: "{\"here\":\"some json\"}"]
    end

    test "validates required attributes" do
      assigns = assigns(%{foo: "foo", bar: "bar"})
      new_assigns = Helpers.set_attributes(assigns, [], required: [:foo])
      assert new_assigns == assigns
    end

    test "with missing required attributes" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      assert_raise ArgumentError, "missing required attributes [:baz]", fn ->
        Helpers.set_attributes(assigns, [], required: [:baz])
      end
    end

    test "with missing required attributes filled" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      assert_raise ArgumentError, "missing required attributes [:baz]", fn ->
        Helpers.set_attributes(assigns, [:baz], required: [:baz])
      end
    end

    test "with required attributes filled with false, it shoud not raise" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      Helpers.set_attributes(assigns, [baz: false], required: [:baz])
    end

    test "with into option, it merges all in a single assign" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      %{
        heex_attributes: [bar: "bar", foo: "foo"],
        heex_bar: [bar: "bar"],
        heex_foo: [foo: "foo"]
      } = Helpers.set_attributes(assigns, [:foo, :bar], into: :attributes)
    end

    test "set default values" do
      assigns = assigns(%{foo: "foo"})

      assert %{
               bar: "bar",
               heex_bar: [bar: "bar"],
               heex_foo: [foo: "foo"]
             } = Helpers.set_attributes(assigns, [:foo, bar: "bar"])
    end

    test "set default nil value" do
      assigns = Helpers.set_attributes(%{}, foo: nil)
      assert %{foo: nil} = assigns
    end

    test "set default json values" do
      assigns = assigns(%{foo: %{here: "some json"}})

      assert %{
               bar: %{there: "also json"},
               heex_bar: [bar: "{\"there\":\"also json\"}"],
               heex_foo: [foo: "{\"here\":\"some json\"}"]
             } = Helpers.set_attributes(assigns, [:foo, bar: %{there: "also json"}], json: true)
    end

    test "set from attributes" do
      assigns = assigns(%{data: [here: "foo", there: "bar"]})
      assert %{heex_here: [here: "foo"]} = Helpers.set_attributes(assigns, [:here], from: :data)

      assert %{heex_here: [here: "foo"], heex_data: [here: "foo"]} =
               Helpers.set_attributes(assigns, [:here], from: :data, into: :data)
    end

    test "detects assign changes" do
      assert %{__changed__: %{id: true}} = Helpers.set_attributes(assigns(%{}), id: 1)
      refute Map.has_key?(Helpers.set_attributes(%{}, id: 1), :__changed__)
    end
  end

  describe "set data attributes" do
    test "with unknown attributes it let the assigns unchanged" do
      assigns = assigns(%{foo: "foo", bar: "bar"})
      new_assigns = Helpers.set_attributes(assigns, [], data: true)
      assert new_assigns == assigns
    end

    test "with known attributes it set the heex attribute" do
      assigns = assigns(%{foo: "foo", bar: "bar"})

      assert %{heex_foo: ["data-foo": "foo"]} =
               Helpers.set_attributes(assigns, [:foo], data: true)
    end

    test "with known attributes and json opt, it set the attribute as json" do
      assigns = %{foo: %{here: "some json"}, bar: "bar"}
      new_assigns = Helpers.set_attributes(assigns, [:foo], data: true, json: true)

      assert new_assigns ==
               Map.put(
                 assigns,
                 :heex_foo,
                 "data-foo": "{\"here\":\"some json\"}"
               )
    end

    test "validates required attributes" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_attributes(assigns, [], required: [:foo], data: true)
      assert new_assigns == assigns
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_attributes(assigns, [], required: [:baz], data: true)
      end
    end

    test "set default values" do
      assigns = %{foo: "foo"}
      new_assigns = Helpers.set_attributes(assigns, [:foo, bar: "bar"], data: true)

      assert new_assigns ==
               assigns
               |> Map.put(:bar, "bar")
               |> Map.put(:heex_foo, "data-foo": "foo")
               |> Map.put(:heex_bar, "data-bar": "bar")
    end

    test "set default json values" do
      assigns = %{foo: %{here: "some json"}}

      new_assigns =
        Helpers.set_attributes(assigns, [:foo, bar: %{there: "also json"}],
          json: true,
          data: true
        )

      assert new_assigns ==
               assigns
               |> Map.put(
                 :bar,
                 %{there: "also json"}
               )
               |> Map.put(
                 :heex_foo,
                 "data-foo": "{\"here\":\"some json\"}"
               )
               |> Map.put(
                 :heex_bar,
                 "data-bar": "{\"there\":\"also json\"}"
               )
    end
  end

  describe "set_prefixed_attributes" do
    test "without phx assigns it let the assigns unchanged" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, [])
      assert new_assigns == assigns
    end

    test "with alpinejs assigns it adds the heex attributes" do
      assigns = %{"@click" => "open = true", "x-bind:class" => "open", foo: "foo"}
      new_assigns = Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"])

      assert new_assigns ==
               assigns
               |> Map.put(:heex_click, "@click": "open = true")
               |> Map.put(:"heex_x-bind:class", "x-bind:class": "open")
    end

    test "with init attributes it adds empty attribute" do
      assigns = %{foo: "foo", bar: "bar"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], init: ["@click.away"])

      assert new_assigns == Map.put(assigns, :"heex_click.away", [])
    end

    test "validates required attributes" do
      assigns = %{"@click.away" => "open = false"}

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])

      assert new_assigns == Map.put(assigns, :"heex_click.away", "@click.away": "open = false")
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_prefixed_attributes(assigns, ["@click", "x-bind:"], required: ["@click.away"])
      end
    end

    test "with single from attribute" do
      assigns = %{rest: [foo: "foo", "phx-click": "click", "phx-update": "ignore"]}
      new_assigns = Helpers.set_prefixed_attributes(assigns, ["phx-"], from: :rest, into: :phx)

      assert new_assigns ==
               assigns
               |> Map.put(:"heex_phx-click", "phx-click": "click")
               |> Map.put(:"heex_phx-update", "phx-update": "ignore")
               |> Map.put(:heex_phx, "phx-click": "click", "phx-update": "ignore")
    end

    test "with multiple from attribute" do
      assigns = %{
        data: [foo: "foo", "data-text": "text"],
        aria: [bar: "bar", "aria-title": "title"]
      }

      new_assigns =
        Helpers.set_prefixed_attributes(assigns, ["data-", "aria-"],
          from: [:data, :aria],
          into: :rest
        )

      assert new_assigns ==
               assigns
               |> Map.put(:"heex_aria-title", "aria-title": "title")
               |> Map.put(:"heex_data-text", "data-text": "text")
               |> Map.put(:heex_rest, "aria-title": "title", "data-text": "text")
    end
  end

  describe "set_phx_attributes" do
    test "with phx assigns it adds the phx-attribute" do
      assigns = %{:"phx-change" => "foo", :"phx-click" => "bar", baz: "baz"}
      new_assigns = Helpers.set_phx_attributes(assigns)

      assert new_assigns ==
               assigns
               |> Map.put(:heex_phx_attributes, "phx-change": "foo", "phx-click": "bar")
               |> Map.put(:"heex_phx-change", "phx-change": "foo")
               |> Map.put(:"heex_phx-click", "phx-click": "bar")
    end

    test "with init attributes it adds empty attribute" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.set_phx_attributes(assigns, init: [:phx_submit], into: nil)
      assert new_assigns == Map.put(assigns, :heex_phx_submit, [])
    end

    test "validates required attributes" do
      assigns = %{:"phx-click" => "click"}
      new_assigns = Helpers.set_phx_attributes(assigns, required: [:"phx-click"], into: nil)
      assert new_assigns == Map.put(assigns, :"heex_phx-click", "phx-click": "click")
    end

    test "with missing required attributes" do
      assigns = %{foo: "foo", bar: "bar"}

      assert_raise ArgumentError, fn ->
        Helpers.set_phx_attributes(assigns, required: [:phx_click])
      end
    end

    test "with from attributes" do
      assigns = %{rest: ["phx-change": "foo", "phx-click": "bar", baz: "baz"]}
      new_assigns = Helpers.set_phx_attributes(assigns, from: :rest)

      assert new_assigns ==
               assigns
               |> Map.put(:heex_phx_attributes, "phx-change": "foo", "phx-click": "bar")
               |> Map.put(:"heex_phx-change", "phx-change": "foo")
               |> Map.put(:"heex_phx-click", "phx-click": "bar")
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
    @tag :capture_log
    test "without class keeps the default class attribute" do
      assigns = %{c: "foo", bar: "bar"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8")

      assert new_assigns ==
               assigns
               |> Map.put(:class, "bg-blue-500 mt-8")
               |> Map.put(:heex_class, class: "bg-blue-500 mt-8")
    end

    test "with class extends the default class attribute" do
      assigns = %{class: "!mt* mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8 ")

      assert new_assigns ==
               %{
                 class: "bg-blue-500 mt-2",
                 heex_class: [class: "bg-blue-500 mt-2"]
               }
    end

    test "can extend other class attribute" do
      assigns = %{wrapper_class: "!mt* mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8 ", attribute: :wrapper_class)

      assert new_assigns ==
               %{
                 wrapper_class: "bg-blue-500 mt-2",
                 heex_wrapper_class: [class: "bg-blue-500 mt-2"]
               }
    end

    test "default classes can be a function" do
      assigns = %{class: "!mt* mt-2", active: true}

      new_assigns =
        Helpers.extend_class(assigns, fn
          %{active: true} -> "bg-blue-500 mt-8"
          _ -> "bg-gray-200 mt-8"
        end)

      assert new_assigns ==
               assigns
               |> Map.put(:class, "bg-blue-500 mt-2")
               |> Map.put(:heex_class, class: "bg-blue-500 mt-2")
    end

    test "does not extend with error_class when a form field is not faulty" do
      assigns = %{
        class: "!mt* mt-2",
        form: %Form{data: %{my_field: "42"}, source: %{errors: []}},
        field: :my_field
      }

      new_assigns =
        Helpers.extend_class(assigns, "bg-blue-500 mt-8", error_class: "form-input-error")

      assert new_assigns ==
               assigns
               |> Map.put(
                 :class,
                 "bg-blue-500 mt-2"
               )
               |> Map.put(
                 :heex_class,
                 class: "bg-blue-500 mt-2"
               )
    end

    test "removes classes prefixed by !" do
      assigns = %{class: "!mt-8 mt-2"}
      new_assigns = Helpers.extend_class(assigns, "bg-blue-500 mt-8", prefix_replace: false)

      assert new_assigns ==
               %{
                 class: "bg-blue-500 mt-2",
                 heex_class: [class: "bg-blue-500 mt-2"]
               }
    end

    test "removes classes prefixed by ! with * patterns" do
      assigns = %{class: "!border* mt-2"}

      new_assigns =
        Helpers.extend_class(assigns, "border-2 border-gray-400", prefix_replace: false)

      assert new_assigns ==
               %{
                 class: "mt-2",
                 heex_class: [class: "mt-2"]
               }
    end

    test "removes everything with !* " do
      assigns = %{class: "!* mt-2"}

      new_assigns =
        Helpers.extend_class(assigns, "border-2 border-gray-400", prefix_replace: false)

      assert new_assigns ==
               %{
                 class: "mt-2",
                 heex_class: [class: "mt-2"]
               }
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

  describe "forward_assigns" do
    test "without options, it returns empty assigns" do
      assigns = %{foo: "foo", bar: "bar"}
      new_assigns = Helpers.forward_assigns(assigns, [])
      assert new_assigns == %{}
    end

    test "with take option" do
      assigns = %{foo: "foo", bar: "bar", baz: "baz"}
      new_assigns = Helpers.forward_assigns(assigns, take: [:bar, :baz])
      assert new_assigns == %{bar: "bar", baz: "baz"}
    end

    test "with prefix option" do
      assigns = %{
        foo: "foo",
        prefix: "prefix",
        prefix_bar: "bar",
        prefix_baz: "baz",
        prefix_nested_prefix_baz: "baz"
      }

      new_assigns = Helpers.forward_assigns(assigns, prefix: :prefix)
      assert new_assigns == %{prefix: "prefix", bar: "bar", baz: "baz", nested_prefix_baz: "baz"}
    end

    test "with take and prefix option" do
      assigns = %{
        foo: "foo",
        bar: "bar",
        prefix_bar: "bar",
        prefix_baz: "baz"
      }

      new_assigns = Helpers.forward_assigns(assigns, prefix: :prefix, take: [:foo])
      assert new_assigns == %{foo: "foo", bar: "bar", baz: "baz"}
    end

    test "only with merge option" do
      assigns = %{
        foo: "foo",
        bar: "bar"
      }

      new_assigns = Helpers.forward_assigns(assigns, merge: %{hello: "world"})
      assert new_assigns == %{hello: "world"}
    end

    test "with prefix & merge options" do
      assigns = %{
        foo: "foo",
        bar: "bar",
        prefix_bar: "bar",
        prefix_baz: "baz"
      }

      new_assigns = Helpers.forward_assigns(assigns, prefix: :prefix, merge: %{hello: "world"})
      assert new_assigns == %{bar: "bar", baz: "baz", hello: "world"}
    end
  end

  describe "has_errors" do
    test "without form it returns false" do
      refute Helpers.has_errors?(%{field: :foo})
    end

    test "without field it returns false" do
      form = %Form{data: %{foo: "42"}, source: %{errors: []}}
      refute Helpers.has_errors?(%{form: form})
    end

    test "with field & form, but no error it returns false" do
      form = %Form{data: %{foo: "42"}}
      refute Helpers.has_errors?(%{form: form, field: :foo})
    end

    test "with field, form, and error it returns true" do
      form = %Form{data: %{foo: "42"}, errors: [foo: [{:some_error, "some error"}]]}
      assert Helpers.has_errors?(%{form: form, field: :foo})
    end
  end
end
