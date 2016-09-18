require 'bootstrap_form'

module BootstrapForm
  class FormBuilder
    def markdown_editor(method, options = {}, html_options = {})
      form_group_builder(method, options, html_options) do
        prepend_and_append_input(options) do
          out = content_tag(:div, '', id: "wmd-button-bar-#{method}")
          html_options = { class: 'wmd-input form-control', id: "wmd-input-#{method}" }
          out += text_area_without_bootstrap(method, options.merge(html_options))
          # TODO: Preview using ajax
          out
        end
      end
    end
  end
end
