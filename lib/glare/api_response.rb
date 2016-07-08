module Glare
  class ApiResponse
    def initialize(response)
      @response = response
    end

    def first_result_id
      result.first['id']
    end

    def contents
      result.map { |item| item['content'] }
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
