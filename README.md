# PhxComponentHelpers

[![github](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml/badge.svg)](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml)
[![codecov](https://codecov.io/gh/cblavier/phx_component_helpers/branch/main/graph/badge.svg)](https://codecov.io/gh/cblavier/phx_component_helpers)

## Presentation

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

## Example

`PhxComponentHelpers` allows you to write components as such:

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
