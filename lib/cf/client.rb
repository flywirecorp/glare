module Cf
  class Client
    BASE_URL = 'https://api.cloudflare.com/client/v4'.freeze

    def initialize(email, auth_key)
      @headers = {
        'Content-Type' => 'application/json',
        'X-Auth-Email' => email,
        'X-Auth-Key' => auth_key
      }
    end

    def get(query, params)
      http = HTTPClient.new
      http.get_content(BASE_URL + query, params, @headers)
    end

    def post(query, data)
      http = HTTPClient.new
      json_data = JSON.generate(data)
      http.post(BASE_URL + query, json_data, @headers)
    end

    def put(query, data)
      http = HTTPClient.new
      json_data = JSON.generate(data)
      http.put(BASE_URL + query, json_data, @headers)
    end
  end
end
