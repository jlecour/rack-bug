if defined?(ActionView) && defined?(ActionView::Template)
  ActionView::Template.class_eval do

    def render_template_with_rack_test(*args, &block)
      result = render_template_without_rack_test(*args, &block)
      Rack::Bug::TemplatesPanel.record(path_without_format_and_extension)
      return result
    end

    alias_method_chain :render_template, :rack_test
  end
end

module Rack
  module Bug
    
    class TemplatesPanel < Panel
      
      def self.record(template)
        Thread.current["rack.bug.templates"] ||= []
        Thread.current["rack.bug.templates"] << template
      end
      
      def self.reset
        Thread.current["rack.bug.templates"] = []
      end
      
      def self.templates
        Thread.current["rack.bug.templates"] || []
      end
      
      def name
        "templates"
      end
      
      def heading
        "Templates"
      end

      def content
        @templates = self.class.templates
        @template = ERB.new ::File.read(::File.dirname(__FILE__) + "/../views/panels/templates.html.erb")
        result = @template.result(binding)
        self.class.reset
        return result
      end
      
    end
    
  end
end