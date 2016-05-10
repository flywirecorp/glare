require 'cf'

describe Cf do
  describe '.register' do
    before do
      ENV['CF_EMAIL'] = 'an_email'
      ENV['CF_AUTH_KEY'] = 'an_auth_key'
    end

    it 'uses default credentials' do
      client = spy(Cf::Client)
      allow(Cf::Client).to receive(:new).and_return(client)

      Cf.register(:a_domain, :a_destination)

      expect(Cf::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses the registration endpoint' do
      client = spy(Cf::Client)
      allow(Cf::Client).to receive(:new).and_return(client)

      Cf.register(:a_domain, :a_destination)

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to match('/client/v4/zones/')
      end
    end
  end
end
