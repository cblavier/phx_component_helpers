# PhxComponentHelpers

This library means at making development of Phoenix LiveView live_components easier.

It allows you to write components as such:

```elixir
defmodule Forms.Button do
  use MyAppWeb, :live_component
  import PhxComponentHelpers

  def mount(socket), do: {:ok, socket}

  def update(assigns, socket) do
    assigns =
      assigns
      |> extend_class("bg-blue-700 hover:bg-blue-900 ...")
      |> set_component_attributes([:type, :id, :label], required: [:label])
      |> set_phx_attributes()

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <button <%= @html_id %> <%= @html_type %> <%= @html_phx_click %> <%= @html_class %>>
      <%= @label %>
    </button>
    """
  end
end
```

You can then use your components like these.

```elixir
= live_component @socket, ButtonGroup, class: "pt-2" do
  = live_component @socket, Button, type: "submit", phx_click: "btn-click", label: "Save"
```

## Installation

Add the following to you `mix.exs`

```elixir
def deps do
  [
    {:phx_component_helpers, "~> 0.1.0"}
  ]
end
```
