module RubyDisqus
  class Request
    attr_reader :api, :path, :options

    # @param [Class<RubyDisqus::Api>] api
    # @param [String] path
    #   @example 'users/details'
    #   @example 'users/details.json'
    # @param [Hash] options
    def initialize(api, path, options = {})
      @api = api
      @path = path.gsub(/^\//, '')
      @path = "#{@path.gsub(/\/$/, '')}.json" unless @path.end_with?('.json')
      @options = options
    end

    # @param [Hash] options
    # @return [String]
    def get(options = {})
      perform(:get, options)
    end

    # @param [Hash] options
    # @return [String]
    def post(options = {})
      perform(:post, options)
    end

    private

    # @param [Symbol] request_type
    # @param [Hash] options
    # @return [String]
    def perform(request_type, options)
      api.connection.public_send(request_type, path, @options.merge(options)).body
    end
  end
end
