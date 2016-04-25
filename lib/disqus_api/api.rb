module DisqusApi
  class Api
    DEFAULT_VERSION = '3.0'
    SERVER_ERROR_CODES = [15, 20, 21].freeze
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
      Faraday.new(connection_options) do |builder|
        builder.use Faraday::Request::Multipart
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Response::ParseJson

        builder.params.merge!(DisqusApi.config.slice(:api_secret, :api_key, :access_token))

        builder.adapter(*DisqusApi.adapter)
      end
    end

    # Performs custom GET request
    # @param [String] path
    # @param [Hash] arguments
    def get(path, arguments = {})
      perform_request { connection.get(path, arguments) }
    end

    # Performs custom POST request
    # @param [String] path
    # @param [Hash] arguments
    def post(path, arguments = {})
      perform_request { connection.post(path, arguments) }
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

    private

    def perform_request
      yield.tap do |response|
        return response.body if success? response
        fail ApiServerError, response.body if server_error? response
        fail InvalidApiRequestError, response.body
      end
    end

    def success?(response)
      response.status == 200 && response.body['code'] == 0
    end

    def server_error?(response)
      response.status / 100 == 5 || SERVER_ERROR_CODES.include?(response.body['code'])
    end
  end
end
