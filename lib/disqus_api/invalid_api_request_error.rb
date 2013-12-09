module DisqusApi
  class InvalidApiRequestError < StandardError
    attr_reader :response

    def initialize(response, message = response.inspect)
      @response = response
      super(message)
    end
  end
end

