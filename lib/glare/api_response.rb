module Glare
  class ApiResponse
    def initialize(response)
      @response = response
    end

    def result
      content['result']
    end

    private

    def content
      @response.content
    end
  end
  private_constant :ApiResponse
end
