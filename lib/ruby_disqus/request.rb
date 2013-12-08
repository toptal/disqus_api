module DisqusApi
  class Request
    attr_reader :api, :path, :options, :namespace, :action, :specification

    class InvalidSpecificationError < Exception
    end

    class InvalidPathError < Exception
    end

    # @param [Class<DisqusApi::Api>] api
    # @param [String] path
    #   @example 'users/details'
    #   @example 'users/details.json'
    # @param [Hash] options Request parameters
    def initialize(api, path, options = {})
      @api = api

      # Remove leading slash from path
      @path = path.gsub(/^\//, '')

      # Namespace is `users`, action is `details`
      @namespace, @action = @path.split('/')

      # Append format to request if needed
      @path = "#{@path.gsub(/\/$/, '')}.json" unless @path.end_with?('.json')

      # Specification used for validation
      @specification = @api.specifications[@namespace][@action]
      case @specification
      when Hash
      when String
        @specification = {type: @specification}
      when nil
        raise InvalidPathError, "The path <#@path> is not registered in API"
      else
        raise InvalidSpecificationError
      end
      @specification = ActiveSupport::HashWithIndifferentAccess.new(@specification)

      validate_specification!

      # Set request parameters
      @options = options
    end

    # @param [Hash] options
    # @return [Hash] Response
    def get(options = {})
      perform(:get, options)
    end

    # @param [Hash] options
    # @return [Hash] Response
    def post(options = {})
      perform(:post, options)
    end

    # @param [Symbol] request_type
    # @param [Hash] options
    # @return [String]
    def perform(request_type, options)
      api.connection.public_send(request_type, path, @options.merge(options)).body
    end
    alias_method :execute, :perform

    # Sends GET request, returns response
    # @return [Hash]
    def self.get(*args)
      perform(:get, *args)
    end

    # Sends POST request, returns response
    # @return [Hash]
    def self.post(*args)
      perform(:post, *args)
    end

    # @see #initialize
    # @param [String, Symbol] request_type
    # @return [Hash]
    def self.perform(request_type, *args)
      case request_type.to_sym
      when :post, :get
        self.new(*args).public_send(request_type)
      else
        raise ArgumentError, "Unregistered request type #{request_type}"
      end
    end

    private

    def validate_specification!
      case @specification[:type]
      when 'post', 'get'
      when nil
        raise InvalidSpecificationError, "Request type is not set"
      else
        raise InvalidSpecificationError, "Undefined request type <#{@specification[:type]}>"
      end
    end
  end
end
