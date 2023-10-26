# PhxComponentHelpers

[![github](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml/badge.svg)](https://github.com/cblavier/phx_component_helpers/actions/workflows/elixir.yml)
[![codecov](https://codecov.io/gh/cblavier/phx_component_helpers/branch/main/graph/badge.svg)](https://codecov.io/gh/cblavier/phx_component_helpers)
[![Hex pm](http://img.shields.io/hexpm/v/phx_component_helpers.svg?style=flat)](https://hex.pm/packages/phx_component_helpers)

👉 [Demonstration & Code samples](https://phx-component-helpers-demo.onrender.com)

## Presentation

`PhxComponentHelpers` provides helper functions meant to be used within Phoenix LiveView to make your components more configurable and extensible from templates.

It provides the following features:

- set HTML, data or phx attributes from component assigns
- set a bunch of attributes at once with any custom prefix such as `@click` or `x-bind:` (for [alpinejs](https://github.com/alpinejs/alpine) users)
- validate mandatory attributes
- set and extend CSS classes from component assigns
- forward a subset of assigns to child components

## Motivation

Writing a library of stateless components is a great way to improve consistency in both your UI and code and also to get a significant productivity boost.

The best components can be used _as-is_ without any further configuration, but are versatile enough to be customized from templates or higher level components.

Writing such components is not difficult, but involves a lot of boilerplate code. `PhxComponentHelpers` is here to alleviate the pain.

## Example

A lot of code samples are available [on this site](https://phx-component-helpers-demo.onrender.com), but basically `PhxComponentHelpers` allows you to write components as such:

```elixir
defmodule Forms.Button do
  use Phoenix.Component
  import PhxComponentHelpers

  def button(assigns) do
    assigns =
      assigns
      |> extend_class("bg-blue-700 hover:bg-blue-900 ...")
      |> set_attributes([:type, :id, :label], required: [:id])
      |> set_phx_attributes()

    ~H"""
    <button {@heex_id} {@heex_type} {@heex_phx_attributes} {@heex_class}>
      <%= @label %>
    </button>
    """
  end
end
```

From templates, it looks like this:

```heex
<.form id="form" phx-submit="form_submit" class="divide-none">

  <.input_group>
    <.label for="name" label="Name"/>
    <.text_input name="name" value={@my.name}/>
  </.input_group>

  <.button_group class="pt-2">
    <.button type="submit" phx-click="btn-click" label="Save"/>
  </.button_group>

</.form>
```

## How does it play with the PETAL stack?

[PETAL](https://thinkingelixir.com/petal-stack-in-elixir/) stands for Phoenix - Elixir - TailwindCSS - Alpine.js - LiveView. In recent months it has become quite popular in the Elixir ecosystem and `PhxComponentHelpers` is meant to fit in.

- [TailwindCSS](https://tailwindcss.com) provides a new way to structure CSS, but keeping good HTML hygiene requires to rely on a component-oriented library.
- [Alpine.js](https://github.com/alpinejs/alpine) is the Javascript counterpart of Tailwind. It lets you define dynamic behaviour right from your templates using HTML attributes.

The point of developing good components is to provide strong defaults in the component so that they can be used _as_-is, but also to let these defaults be overridden right from the templates.

Here is the definition of a typical Form button, with `Tailwind` & `Alpine`:

```elixir
defmodule Forms.Button do
  use Phoenix.Component
  import PhxComponentHelpers

  @css_class "inline-flex items-center justify-center p-3 w-5 h-5 border \
              border-transparent text-2xl leading-4 font-medium rounded-md \
              text-white bg-primary hover:bg-primary-hover"

  def button(assigns) do
    assigns =
      assigns
      |> extend_class(@css_class)
      |> set_phx_attributes()
      |> set_prefixed_attributes(["@click", "x-bind:"],
        into: :alpine_attributes,
        required: ["@click"]
      )

    ~H"""
    <button type="button" {@heex_class} {@heex_alpine_attributes} {@heex_phx_attributes}>
      <%= render_block(@inner_block) %>
    </button>
    """
  end
end
```

Then in your `html.heex` template you can imagine the following code, providing `@click` behaviour and overriding just the few tailwind css classes you need (only `p-*`, `w-*` and `h-*` will be replaced). No `phx` behaviour here, but it's ok, it won't break ;-)

```elixir
<.button class="!p-* p-0 !w-* w-7 !h-* h-7" "@click"="$dispatch('closeslideover')">
  <.icon icon={:plus_circle}/>
</.button>
```

## Forms

This library also provides `Phoenix.HTML.Form` related functions so you can easily write your own `my_form_for` function with your css defaults.

```elixir
def my_form_for(options) when is_list(options) do
  options
  |> extend_form_class("mt-4 space-y-2")
  |> Phoenix.LiveView.Helpers.form()
end
```

Then you only need to use `PhxComponentHelpers.set_form_attributes/1` within your own form components in order to fetch names & values from the form. Your template will then look like this:

```heex
<.my_form_for let={f} for={@changeset} phx-submit="form_submit" class="divide-none">
  <.input_group>
    <.label form={f} field={:name} label="Name"/>
    <.text_input form={f} field={:name}/>
  </.input_group>

  <.button_group class="pt-2">
    <.button type="submit" label="Save"/>
  </.button_group>
</.my_form_for>
```

## Compared to Surface

[Surface](https://github.com/surface-ui/surface) is a library built on top of Phoenix LiveView. Surface is much more ambitious and complex than `PhxComponentHelpers` (which obviously isn't a framework, just helpers ...).

`Surface` really changes the way you code user interfaces and components (you almost won't be using HTML templates anymore) whereas `PhxComponentHelpers` is just some syntactic sugar to help you use raw `phoenix_live_view`.

## Documentation

Available on [https://hexdocs.pm](https://hexdocs.pm/phx_component_helpers)

## Installation

Add the following to your `mix.exs`.

```elixir
def deps do
  [
    {:phx_component_helpers, "~> 1.4.0"},
    {:jason, "~> 1.0"} # only required if you want to use json encoding options
  ]
end
```
