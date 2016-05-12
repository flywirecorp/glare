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
    let(:zone_list) { '{"result":[{"id":"9de4eb694c380d79845d35cd939cc7a7","name":"example.com","status":"pending","paused":false,"type":"full","development_mode":0,"name_servers":["coco.ns.cloudflare.com","jeff.ns.cloudflare.com"],"original_name_servers":["ns-121.awsdns-15.com","ns-1288.awsdns-33.org","ns-2032.awsdns-62.co.uk","ns-734.awsdns-27.net"],"original_registrar":null,"original_dnshost":null,"modified_on":"2016-05-12T10:19:14.185994Z","created_on":"2016-05-12T10:15:06.531372Z","checked_on":"2016-05-12T10:20:14.209689Z","meta":{"step":4,"wildcard_proxiable":false,"custom_certificate_quota":0,"page_rule_quota":3,"phishing_detected":false,"multiple_railguns_allowed":false},"owner":{"type":"user","id":"dbaf2b4d4317b92cbc3b1820a5eaf6d3","email":"josacar@gmail.com"},"permissions":["#analytics:read","#billing:edit","#billing:read","#cache_purge:edit","#dns_records:edit","#dns_records:read","#lb:edit","#lb:read","#logs:read","#organization:edit","#organization:read","#ssl:edit","#ssl:read","#waf:edit","#waf:read","#zone:edit","#zone:read","#zone_settings:edit","#zone_settings:read"],"plan":{"id":"0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee","name":"Free Website","price":0,"currency":"USD","frequency":"","legacy_id":"free","is_subscribed":true,"can_subscribe":true,"externally_managed":false}}],"result_info":{"page":1,"per_page":20,"total_pages":1,"count":1,"total_count":1},"success":true,"errors":[],"messages":[]}' }

    it 'uses default credentials' do
      Cf.register('example.com', :a_destination)

      expect(Cf::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses a base URL' do
      Cf.register('example.com', :a_destination)

      expect(Cf::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses the registration endpoint' do
      Cf.register('example.com', :a_destination)

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to match(%r{/zones/.*/dns_records})
      end
    end

    it 'gathers zone id for a given name' do
      Cf.register('example.com', :a_destination)

      expect(client).to have_received(:post).with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records')
    end
  end
end
