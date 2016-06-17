require 'jsonclient'

module Cf
  class Client
    BASE_URL = 'https://api.cloudflare.com/client/v4'.freeze

    def initialize(email, auth_key)
      @headers = {
        'Content-Type' => 'application/json',
        'X-Auth-Email' => email,
        'X-Auth-Key' => auth_key
      }
      @http = JSONClient.new
      @http.debug_dev = STDERR if ENV['CF_DEBUG']
    end

    def get(query, params)
      @http.get(BASE_URL + query, params, @headers)
    end

    def post(query, data)
      @http.post(BASE_URL + query, data, @headers)
    end

    def put(query, data)
      @http.put(BASE_URL + query, data, @headers)
    end

    def delete(query, params=nil)
      @http.delete(BASE_URL + query, params, @headers)
    end
  end
end
