require 'bootstrap_form'

module BootstrapForm
  class FormBuilder
    def markdown_editor(method, options = {}, html_options = {})
      id = options[:id] || method

      form_group_builder(method, options, html_options) do
        content_tag(:div, '', id: "wmd-button-bar-#{id}") do
          html_options = { class: 'wmd-input form-control', id: "wmd-input-#{id}" }
          # TODO: preview using ajax
          text_area_without_bootstrap(method, options.merge(html_options))
        end
      end
    end
  end
end
