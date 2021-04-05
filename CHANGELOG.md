# 0.8.0
- `PhxComponentHelpers.set_form_attributes/3` will now set default form attributes when keys
exist but are nil
- `PhxComponentHelpers.set_component_attributes/3` and PhxComponentHelpers.set_data_attributes/3
can now take default values

# 0.7.0
- `PhxComponentHelpers.set_form_attributes/3` will now init form data with nil values
when no form/field is provided
- `PhxComponentHelpers.set_form_attributes/3` retrieves and assigns form errors
- `PhxComponentHelpers.extend_class/2` now supports new `:error_class` option to
extend CSS classes when a form field is faulty

# 0.6.0
- added `PhxViewHelpers` than can be used within templates
- added `PhxComponentHelpers.set_form_attributes/3` to fetch `Phoenix.HTML.Form` data

# 0.5.0
- all assigns are no longer prefixed by `html_` but by `raw_`
- new `:into` option is 
- `set_phx_attributes/2` has a default `:into` option
- `extend_class/2` changes its signature to also use `into`

# 0.4.0
- `set_component_attributes/3` will set absent assigns by default
- removed `:init` option from `set_component_attributes/3`
- added `validate_required_attributes/2` 

# 0.3.0
- New `set_prefixed_attributes/3` function that can be used to map alpinejs attributes

# 0.2.0
- Fixed issue when `Jason` library is not available
- Removed hardcoded list of `phx_*` attributes

# 0.1.0
Initial release :)