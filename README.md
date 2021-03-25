# PhxComponentHelpers

[![github](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml/badge.svg)](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml)
[![codecov](https://codecov.io/gh/cblavier/phx_component_helpers/branch/main/graph/badge.svg)](https://codecov.io/gh/cblavier/phx_component_helpers)

## Presentation

`PhxComponentHelpers` are helper functions meant to be used within Phoenix LiveView live_components to make your components more configurable and extensible
from your templates.

It provides the following features:

 * set HTML attributes from component assigns
 * set data attributes from component assigns
 * set phx_* attributes from component assigns
 * encode attributes as JSON from an Elixir structure assign
 * validate mandatory attributes
 * set and extend CSS classes from component assigns

## Example

`PhxComponentHelpers` allows you to write components as such:

```elixir
defmodule Forms.Button do
  use Phoenix.LiveComponent
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

From your templates, it's looking like this:

```elixir
<%= live_component @socket, Form, id: "form", phx_submit: "form_submit", class: "divide-none" do %>
  <%= live_component @socket, InputGroup do %>
    <%= live_component @socket, Label, for: "name", label: "Name" %>
    <%= live_component @socket, TextInput, name: "name", value: @my.name %>
  <% end %>
    
  <%= live_component @socket, ButtonGroup, class: "pt-2" do %>
    <%= live_component @socket, Button, type: "submit", phx_click: "btn-click", label: "Save" %>
  <% end %>
<% end %>
```

## Compared to Surface

[Surface](https://github.com/surface-ui/surface) is a library built on the top of Phoenix LiveView and `live_components`. Surface is much more ambitious, heavier, and complex than `PhxComponentHelpers` is (which obviously isn't a framework, just helpers ...).

`Surface` really changes the way you code user interfaces and components (you almost won't be using HTML templates anymore) whereas `PhxComponentHelpers` are just some sugar to help you using raw `phoenix_live_view`.


## Documentation

Available on [https://hexdocs.pm](https://hexdocs.pm/phx_component_helpers)

## Installation

Add the following to your `mix.exs`.


```elixir
def deps do
  [
    {:phx_component_helpers, "~> 0.3.0"},
    {:jason, "~> 1.0"} # only required if you want to use json encoding options
  ]
end
```

