module RubyDisqus
  class Api
    DEFAULT_VERSION = '3.0'
    attr_reader :version, :endpoint, :specifications, :namespaces

    # @param [String] version
    # @param [Hash] specifications API specifications
    def initialize(version = DEFAULT_VERSION, specifications = {})
      @version = version
      @endpoint = "https://disqus.com/api/#@version/".freeze
      @specifications = ActiveSupport::HashWithIndifferentAccess.new(specifications)

      @namespaces = ActiveSupport::HashWithIndifferentAccess.new
      @specifications.keys.each do |namespace|
        @namespaces[namespace] = Namespace.new(self, namespace)
      end
    end

    # @return [Hash]
    def connection_options
      {
        headers: { 'Accept' => "application/json", 'User-Agent' => "DisqusAgent"},
        ssl: { verify: false },
        url: @endpoint
      }
    end

    # @return [Faraday]
    def connection
      @connection ||= begin
        Faraday.new(connection_options) do |builder|
          builder.adapter(Faraday.default_adapter)

          builder.use Faraday::Request::Multipart
          builder.use Faraday::Request::UrlEncoded
          builder.use Faraday::Response::ParseJson

          # TODO: check if can merge params
          builder.params['api_secret']   = RubyDisqus.config[:api_secret]
          builder.params['api_key']      = RubyDisqus.config[:api_key]
          builder.params['access_token'] = RubyDisqus.config[:access_token]
        end
      end
    end

    def method_missing(method_name, *args)
      if self.respond_to?(method_name)
        super
      else
        namespaces[method_name] || super
      end
    end

    private

    class Namespace
      attr_reader :api, :namespace, :specification

      def initialize(api, namespace)
        @api = api
        @namespace = namespace
        @specification = @api.specifications[@namespace]
        @specification or raise(ArgumentError, "No such namespace <#@namespace>")
      end

      def method_missing(method_name, *args)
        request_endpoint = specification[method_name]

        if request_endpoint
          ::RubyDisqus::Request.new(api, "#@namespace/#{method_name}", *args).public_send(request_endpoint)
        else
          super
        end
      end
    end
  end
end
