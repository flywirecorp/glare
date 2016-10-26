require 'jsonclient'
require 'glare/api_response'

module Glare
  class Client
    BASE_URL = 'https://api.cloudflare.com/client/v4'.freeze

    def initialize(email, auth_key)
      @headers = {
        'X-Auth-Email' => email,
        'X-Auth-Key' => auth_key
      }
      @http = JSONClient.new
      @http.debug_dev = STDERR if ENV['CF_DEBUG']
    end

    def get(query, params)
      ApiResponse.new(@http.get(BASE_URL + query, params, @headers)).valid!
    end

    def post(query, data)
      ApiResponse.new(@http.post(BASE_URL + query, data, @headers)).valid!
    end

    def put(query, data)
      ApiResponse.new(@http.put(BASE_URL + query, data, @headers)).valid!
    end

    def delete(query, params=nil)
      ApiResponse.new(@http.delete(BASE_URL + query, params, @headers)).valid!
    end
  end
end
