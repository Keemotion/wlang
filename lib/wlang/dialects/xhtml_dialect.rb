require 'cgi'
module WLang
  class EncoderSet
    
    # Defines encoders of the whtml dialect
    module XHtml
  
      # Default encoders  
      DEFAULT_ENCODERS = {"main-encoding"     => :entities_encoding,
                          "single-quoting"    => :single_quoting,
                          "double-quoting"    => :double_quoting,
                          "entities-encoding" => :entities_encoding}
  
  
      # Single-quoting encoding
      def self.single_quoting(src, options); src.gsub(/([^\\])'/,%q{\1\\\'}); end
  
      # Double-quoting encoding
      def self.double_quoting(src, options); src.gsub('"','\"'); end
    
      # Entities-encoding
      def self.entities_encoding(src, options); 
        CGI::escapeHTML(src)
      end
  
    end # module XHtml  
  end
  class RuleSet
    
    # Defines rulset of the wlang/xhtml dialect
    module XHtml
    
      # Default mapping between tag symbols and methods
      DEFAULT_RULESET = {'@' => :at}
  
      def self.at(parser, offset)
        # parse the url
        url, reached = parser.parse(offset, 'wlang/active-string')
        url = WLang::encode(url, 'wlang/xhtml/double-quoting')
        
        # parse the label if there is one
        label = nil
        if parser.has_block?(reached)
          label, reached = parser.parse_block(reached) 
          label = WLang::encode(label, 'wlang/xhtml/entities-encoding')
        end
        
        if label and url.respond_to?(:to_xhtml_link)
          [url.to_xhtml_link(url, label), reached]
        elsif url.respond_to?(:to_xhtml_href)
          [url.to_xhtml_href(url), reached]
        elsif label
          ["<a href=\"#{url}\">#{label}</a>", reached]
        else
          [url, reached]
        end
      end
  
    end # module XHtml
    
  end
end

