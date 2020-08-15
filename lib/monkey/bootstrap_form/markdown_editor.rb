require 'bootstrap_form'

module BootstrapForm
  class FormBuilder
    def markdown_editor(field, options = {}, html_options = {})
      id = options[:id] || field
      escape = !options[:no_escape]

      form_group_builder(field, options, html_options) do
        html = content_tag(:div, tabs(id, escape), class: 'nav nav-tabs', role: 'tablist')
        html.concat content_tag(:div, tab_content(id, field, options), class: 'tab-content')
        html
      end
    end

    private

    def tabs(id, escape)
      html = content_tag(:a, 'Markdown', class: 'nav-item nav-link active', id: "wmd-input-tab-#{id}",
                                         href: "#wmd-input-panel-#{id}", role: 'tab', data: { toggle: 'tab' },
                                         'aria-controls' => "wmd-input-panel-#{id}", 'aria-selected' => 'true')

      html.concat content_tag(:a, 'Preview', class: 'nav-item nav-link', id: "wmd-preview-tab-#{id}",
                                             href: "#wmd-preview-panel-#{id}", role: 'tab',
                                             data: { toggle: 'tab', 'markdown-preview' => "wmd-preview-#{id}",
                                                     'markdown-source' => "wmd-input-#{id}",
                                                     'markdown-escape' => escape },
                                             'aria-controls' => "wmd-preview-panel-#{id}", 'aria-selected' => 'false')

      html
    end

    def tab_content(id, field, options)
      # Input tab
      html_options = { class: ['wmd-input form-control'], id: "wmd-input-#{id}" }
      html_options[:class] << 'is-invalid' if error? field

      input_text_area = text_area_without_bootstrap(field, options.merge(html_options))
      input_text_area.concat generate_error(field)

      input = content_tag(:div, input_text_area, id: "wmd-button-bar-#{id}")

      html = content_tag(:div, input, class: 'tab-pane show active', id: "wmd-input-panel-#{id}", role: 'tabpanel',
                                      'aria-labelledby' => "wmd-input-tab-#{id}")

      # Preview tab
      rows = options[:rows] || 20

      preview = content_tag(:div, '', class: 'markdown preview', id: "wmd-preview-#{id}",
                                      style: "height: #{rows * 2}em;")

      html.concat content_tag(:div, preview, class: 'tab-pane', id: "wmd-preview-panel-#{id}", role: 'tabpanel',
                                             'aria-labelledby' => "wmd-preview-tab-#{id}")

      html
    end
  end
end
