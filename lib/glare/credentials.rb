module Glare
  class Credentials
    def initialize(email, auth_key)
      @email = email
      @auth_key = auth_key
    end

    attr_reader :email, :auth_key
  end
end
