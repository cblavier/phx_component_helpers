# 0.12.0
- now injecting heex_attributes into assigns that can be used from heex templates
- switched examples to `live_component` without socket syntax
- new `PhxComponentHelpers.has_errors?/1` function
- `validate_required_attributes/2` now raises a more comprehensive exception

# 0.11.0
- `PhxComponentHelpers.forward_assigns/2` with prefix :icon will now forward all `:icon_*` keys and `:icon` as well
- removed `error_class` option on `PhxComponentHelpers.extend_class/2` which can now be handled
by using a function as the first parameter
- merged [first PR](https://github.com/cblavier/phx_component_helpers/pull/2) (mainly english mistakes ... 🇫🇷) ;-)

# 0.10.0 
- new `:merge` option on `PhxComponentHelpers.forward_assigns/2`
- `PhxComponentHelpers.extend_class/2` can now take defaults as a function

# 0.9.0
- renamed `PhxComponentHelpers.set_component_attributes/3` into `PhxComponentHelpers.set_attributes/3`
- removed `PhxComponentHelpers.set_data_attributes/3` which has been replaced by a `data: true` option passed to `PhxComponentHelpers.set_attributes/3`
- new `PhxComponentHelpers.forward_assigns/2` to pass assigns to child components

# 0.8.1
- fixed default attributes behavior

# 0.8.0
- `:into` option of `PhxComponentHelpers.extend_class/2` is renamed in `:attribute`
- `PhxComponentHelpers.extend_class/2` will overwrite input assign class with extended class
- `PhxComponentHelpers.set_form_attributes/1` will now set default form attributes when keys
exist but are nil
- `PhxComponentHelpers.set_attributes/3` and PhxComponentHelpers.set_data_attributes/3
can now take default values

# 0.7.0
- `PhxComponentHelpers.set_form_attributes/1` will now init form data with nil values
when no form/field is provided
- `PhxComponentHelpers.set_form_attributes/1` retrieves and assigns form errors
- `PhxComponentHelpers.extend_class/2` now supports new `:error_class` option to
extend CSS classes when a form field is faulty

# 0.6.0
- added `PhxViewHelpers` than can be used within templates
- added `PhxComponentHelpers.set_form_attributes/1` to fetch `Phoenix.HTML.Form` data

# 0.5.0
- all assigns are no longer prefixed by `html_` but by `raw_`
- new `:into` option is 
- `set_phx_attributes/2` has a default `:into` option
- `extend_class/2` changes its signature to also use `into`

# 0.4.0
- `set_attributes/3` will set absent assigns by default
- removed `:init` option from `set_attributes/3`
- added `validate_required_attributes/2` 

# 0.3.0
- New `set_prefixed_attributes/3` function that can be used to map alpinejs attributes

# 0.2.0
- Fixed issue when `Jason` library is not available
- Removed hardcoded list of `phx_*` attributes

# 0.1.0
Initial release :)