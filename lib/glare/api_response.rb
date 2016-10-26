module Glare
  class ApiResponse
    def initialize(response)
      @response = response
    end

    def result
      content['result']
    end

    def valid!
      raise Glare::Errors::ApiError unless success?
      self
    end

    private

    def success?
      content['success']
    end

    def content
      @response.content
    end
  end
end
