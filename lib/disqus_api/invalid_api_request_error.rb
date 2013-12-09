module DisqusApi
  class InvalidApiRequestError < Exception
    def initialize(response, message = response.inspect)
      super(response)
    end
  end
end

