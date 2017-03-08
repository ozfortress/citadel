require 'markdown'

module MarkdownRenderCaching
  extend ActiveSupport::Concern

  class_methods do
    def caches_markdown_render_for(attribute, options = {})
      render_cached_attributes[attribute] = transform_render_cache_options(attribute, options)

      before_validation do
        reset_render_cache(attribute) if changed_attributes[attribute.to_s] || new_record?
      end
    end

    def render_cached_attributes
      @render_cached_attributes ||= {}
    end

    private

    def transform_render_cache_options(attribute, options)
      options[:cache_attribute] ||= "#{attribute}_render_cache"
      options[:escaped] = options[:escaped] != false
      options
    end
  end

  def reset_render_caches(attributes = nil)
    (attributes || self.class.render_cached_attributes.keys).each do |attribute|
      reset_render_cache(attribute)
    end
  end

  def reset_render_caches!(attributes = nil)
    reset_render_caches(attributes)
    save!
  end

  def reset_render_cache(attribute)
    options = self.class.render_cached_attributes[attribute]

    source = send(attribute)
    render = MarkdownRenderer.render(source, options[:escaped])

    cache_attribute = options[:cache_attribute]
    send("#{cache_attribute}=", render)
  end

  def reset_render_cache!(attribute)
    reset_render_cache(attribute)
    save!
  end
end
