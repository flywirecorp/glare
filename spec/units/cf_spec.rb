require 'cf'

describe Cf do
  describe '.register' do
    before do
      ENV['CF_EMAIL'] = 'an_email'
      ENV['CF_AUTH_KEY'] = 'an_auth_key'

      allow(Cf::Client).to receive(:new).and_return(client)
      allow(client).to receive(:get).
        with('/zones', name: 'example.com').
        and_return(zone_list)
    end
    let(:client) { spy(Cf::Client) }
    let(:zone_list) { load_fixture('list_zone') }

    it 'uses default credentials' do
      Cf.register('example.com', :a_destination, 'CNAME')

      expect(Cf::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses a base URL' do
      Cf.register('example.com', :a_destination, 'CNAME')

      expect(Cf::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses the registration endpoint' do
      Cf.register('example.com', :a_destination, 'CNAME')

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to match(%r{/zones/.*/dns_records})
      end
    end

    it 'retrieves zone id for a given domain name' do
      Cf.register('example.com', :a_destination, 'CNAME')

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to eq('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records')
      end
    end

    it 'sends registration data to endpoint' do
      Cf.register('example.com', :a_destination, 'CNAME')

      expect(client).to have_received(:post).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        type: 'CNAME', name: 'example.com', content: :a_destination
      )
    end
  end

  def load_fixture(fixture)
    fixture_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures'))
    IO.read(File.join(fixture_dir, "#{fixture}.json"))
	end
end
