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

    # @param [String, Symbol] action
    # @param [Hash] arguments Action params
    # @return [Request]
    def build_action_request(action, arguments = {})
      Request.new(api, namespace, action, arguments)
    end

    # @param [String, Symbol, Hash] action
    # @param [Hash] arguments
    # @return [Hash] response
    def request_action(action, arguments = {})
      build_action_request(action, arguments).perform
    end
    alias_method :perform_action, :request_action

    # DisqusApi.v3.users.---->>[details]<<-----
    #
    # Forwards all API calls under a specific namespace
    def method_missing(method_name, *args)
      request_action(method_name, *args)
    end
  end
end