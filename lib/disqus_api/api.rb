module DisqusApi
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

    # @return [Faraday::Connection]
    def connection
      @connection ||= begin
        Faraday.new(connection_options) do |builder|
          builder.adapter(*Faraday.default_adapter)

          builder.use Faraday::Request::Multipart
          builder.use Faraday::Request::UrlEncoded
          builder.use Faraday::Response::ParseJson

          builder.params.merge!(DisqusApi.config)
        end
      end
    end

    # Performs custom GET request
    # @param [String] path
    # @param [Hash] arguments
    def get(path, arguments = {})
      connection.get(path, arguments).body
    end

    # Performs custom POST request
    # @param [String] path
    # @param [Hash] arguments
    def post(path, arguments = {})
      connection.post(path, arguments).body
    end

    # DisqusApi.v3.---->>[users]<<-----.details
    #
    # Forwards calls to API declared in YAML
    def method_missing(method_name, *args)
      namespaces[method_name] or raise(ArgumentError, "No such namespace #{method_name}")
    end

    def respond_to?(method_name, include_private = false)
      namespaces[method_name] || super
    end
  end
end
