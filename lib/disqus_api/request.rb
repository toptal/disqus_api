module DisqusApi
  class Request
    attr_reader :api, :path, :namespace, :action, :arguments, :type

    # @param [Class<DisqusApi::Api>] api
    # @param [String] namespace
    # @param [String] action
    # @param [Hash] arguments Request parameters
    def initialize(api, namespace, action, arguments = {})
      @api = api
      @namespace = namespace.to_s
      @action = action.to_s
      @path = "#@namespace/#@action.json"

      # Request type GET or POST
      namespace_specification = @api.specifications[@namespace] or raise(ArgumentError, "No such namespace: #@namespace")
      @type = namespace_specification[@action].try(:to_sym) or raise(ArgumentError, "No such API path: #@path")

      # Set request parameters
      @arguments = arguments
    end

    # @param [Symbol] request_type
    # @param [Hash] arguments
    # @return [String]
    def perform(arguments = {})
      case type.to_sym
      when :post, :get
        api.public_send(type, path, @arguments.merge(arguments))
      else
        raise ArgumentError, "Unregistered request type #{request_type}"
      end
    end
    alias_method :execute, :perform

    # @see #initialize
    # @param [String, Symbol] request_type
    # @return [Hash]
    def self.perform(*args)
      self.new(*args).perform
    end
  end
end
