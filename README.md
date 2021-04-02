# PhxComponentHelpers

[![github](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml/badge.svg)](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml)
[![codecov](https://codecov.io/gh/cblavier/phx_component_helpers/branch/main/graph/badge.svg)](https://codecov.io/gh/cblavier/phx_component_helpers)
[![Hex pm](http://img.shields.io/hexpm/v/phx_component_helpers.svg?style=flat)](https://hex.pm/packages/phx_component_helpers)

## Presentation

`PhxComponentHelpers` are helper functions meant to be used within Phoenix LiveView live_components to make your components more configurable and extensible from templates.

It provides the following features:

 * set HTML attributes from component assigns
 * set data attributes from component assigns
 * set phx_* attributes from component assigns
 * set attributes with any custom prefix such as `@click` or `x-bind:` from [alpinejs](https://github.com/alpinejs/alpine)
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
      |> set_component_attributes([:type, :id, :label], required: [:id])
      |> set_phx_attributes()

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <button <%= @raw_id %> <%= @raw_type %> <%= @raw_phx_attributes %> <%= @raw_class %>>
      <%= @label %>
    </button>
    """
  end
end
```

From templates, it's looking like this:

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

## With the PETAL stack

[PETAL](https://thinkingelixir.com/petal-stack-in-elixir/) stands for Phoenix - Elixir - TailwindCSS - Alpine.js - LiveView. In recent months it became quite popular in the Elixir ecosystem and `PhxComponentHelpers` are meant to fit in.

- [TailwindCSS](https://tailwindcss.com) provides a new way to structure CSS but keeping a good HTML hygien required to rely on a component oriented library.
- [Alpine.js](https://github.com/alpinejs/alpine) is the Javascript counterpart of Tailwind. It let you define dynamic behaviour right from your templates with HTML attributes.

The point of developping good components is to provide strong defaults in the component so that they can be used as-is. But also to let these defaults be overriden right from the templates.

Here is the definition of a typical Form button, with `Tailwind` & `Alpine`:

```elixir
defmodule Forms.Button do
  use Phoenix.LiveComponent
  import PhxComponentHelpers

  @css_class "inline-flex items-center justify-center p-3 w-5 h-5 border \
              border-transparent text-2xl leading-4 font-medium rounded-md \
              text-white bg-primary hover:bg-primary-hover"

  def mount(socket), do: {:ok, socket}

  def update(assigns, socket) do
    assigns =
      assigns
      |> extend_class(@css_class)
      |> set_phx_attributes()
      |> set_prefixed_attributes(
        ["@click", "x-bind:"],
        into: :alpine_attributes,
        required: "@click"
      )

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <button type="button"
      <%= @raw_class %> 
      <%= @raw_alpine_attributes %> 
      <%= @raw_phx_attributes%>
     >
      <%= render_block(@inner_block) %>
    </button>
    """
  end
end
```

Then in your `html.leex` template you can imagine the following code, providing `@click` behaviour and overriding just the few tailwind css classes you need (only `p-*`, `w-*` and `h-*` will be replaced). No `phx` behaviour here, but it's ok it won't break ;-)

```elixir
<%= live_component @socket, Button, class: "p-0 w-7 h-7", "@click": "$dispatch('closeslideover')" do %>
  <%= live_component @socket, Icon, icon: :plus_circle %>
<% end %>
```

## Forms
This library also provides `Phoenix.HTML.Form` related functions so you can easily write your own `my_form_for` function with your css defaults.

```elixir
def my_form_for(form_data, action, options) when is_list(options) do
  new_options = extend_form_class(options, "mt-4 space-y-2")
  form_for(form_data, action, new_options)
end
```

Then you only needs to use `PhxComponentHelpers.set_form_attributes/3` within your own form LiveComponents in order to fetch names & values from the form. Your template will then look like this:

```elixir
<%= f = my_form_for @changeset, "#", phx_submit: "form_submit", class: "divide-none" do %>
  <%= live_component @socket, InputGroup do %>
    <%= live_component @socket, Label, form: f, field: :name, label: "Name" %>
    <%= live_component @socket, TextInput, form: f, field: :name  %>
  <% end %>
    
  <%= live_component @socket, ButtonGroup, class: "pt-2" do %>
    <%= live_component @socket, Button, type: "submit", label: "Save" %>
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
    {:phx_component_helpers, "~> 0.7.0"},
    {:jason, "~> 1.0"} # only required if you want to use json encoding options
  ]
end
```

