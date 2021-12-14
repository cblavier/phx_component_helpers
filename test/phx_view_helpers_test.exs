defmodule PhxViewHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias PhxViewHelpers, as: Helpers

  describe "extend_form_class" do
    test "without class keeps the default class attribute" do
      opts = [c: "foo", bar: "bar"]
      new_opts = Helpers.extend_form_class(opts, "bg-blue-500 mt-8")
      assert new_opts == Keyword.put(opts, :class, "mt-8 bg-blue-500")
    end

    test "with class extends the default class attribute" do
      opts = [class: "mt-2"]
      new_opts = Helpers.extend_form_class(opts, "bg-blue-500 mt-8 ")
      assert new_opts == Keyword.put(opts, :class, "bg-blue-500 mt-2")
    end

    test "with class extends the default class attribute as map" do
      assigns = %{class: "mt-2"}
      new_assigns = Helpers.extend_form_class(assigns, "bg-blue-500 mt-8 ")
      assert new_assigns == Map.put(assigns, :class, "bg-blue-500 mt-2")
    end
  end
end
