module DisqusApi
  class Namespace
    attr_reader :api, :namespace, :specification

    # @param [Api] api
    # @param [String, Symbol] namespace
    def initialize(api, namespace)
      @api = api
      @namespace = namespace
      @specification = @api.specifications[@namespace]
      @specification or raise(ArgumentError, "No such namespace <#@namespace>")
    end

    def build_request(action, arguments = {})
      request_endpoint = specification[action]
      request_path = "#@namespace/#{action}"

      case request_endpoint
        when String, Symbol
          ::DisqusApi::Request.perform(request_endpoint, request_path, action, arguments)
        when Hash
          request = ::DisqusApi::Request.new(api, request_path, arguments)
          request.validate!
          request.public_send(request_endpoint['type'])
        else
          raise NoActionError, "The action #{request_path} is not included in API v#{api.version}"
      end
    end

    # @param [String, Symbol, Hash] action
    # @param [Hash] arguments
    # @return [Hash] response
    def send_request(action, arguments = {})
      request_endpoint = specification[action]
      request_path = "#@namespace/#{action}"

      case request_endpoint
        when String, Symbol
          ::DisqusApi::Request.perform(request_endpoint, request_path, action, arguments)
        when Hash
          request = ::DisqusApi::Request.new(api, request_path, arguments)
          request.validate!
          request.public_send(request_endpoint['type'])
        else
          raise NoActionError, "The action #{request_path} is not included in API v#{api.version}"
      end
    end

    # DisqusApi.v3.users.---->>[details]<<-----
    #
    # Forwards all API calls under a specific namespace
    def method_missing(method_name, *args)
      send_request(method_name, *args) || super
    end

    class NoActionError < Exception
    end
  end
end