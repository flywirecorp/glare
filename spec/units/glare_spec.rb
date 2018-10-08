require 'glare'

RSpec.describe Glare do
  before do
    allow(ENV).to receive(:[]).with('CF_EMAIL').and_return('an_email')
    allow(ENV).to receive(:[]).with('CF_AUTH_KEY').and_return('an_auth_key')

    allow(Glare::Client).to receive(:new).and_return(client)
  end
  let(:client) { spy(Glare::Client) }
  let(:zone_list) { Glare::ApiResponse.new(load_fixture('list_zone')) }
  let(:empty_result) { Glare::ApiResponse.new(load_fixture('empty_result')) }
  let(:wadus_records) do
    [
      Glare::ApiResponse.new(load_fixture('wadus_records')),
      Glare::ApiResponse.new(load_fixture('wadus_records_reverse_order'))
    ].sample
  end

  describe '.resolve' do
    it 'resolves a fqdn' do
      allow(client).to receive(:get).
        with('/zones', name: 'example.com').
        and_return(zone_list)

      allow(client).to receive(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'wadus.example.com', type: 'CNAME'
      ).and_return(wadus_records)

      destination = Glare.resolve('wadus.example.com', 'CNAME')
      expect(destination).to match_array(['destination.com', 'another_destination.com'])
    end
  end

  describe '.register' do
    before do
      allow(client).to receive(:get).
        with('/zones', name: 'example.com').
        and_return(zone_list)

      allow(client).to receive(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'example.com', type: 'CNAME'
      ).and_return(empty_result)
    end

    it 'uses default credentials' do
      Glare.register('example.com', 'a_destination', 'CNAME')

      expect(Glare::Client).to have_received(:new).with('an_email', 'an_auth_key')
    end

    it 'uses the registration endpoint' do
      Glare.register('example.com', 'a_destination', 'CNAME')

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to match(%r{/zones/.*/dns_records})
      end
    end

    it 'retrieves zone id for a given domain name' do
      Glare.register('example.com', 'a_destination', 'CNAME')

      expect(client).to have_received(:get).
        with('/zones', name: 'example.com')

      expect(client).to have_received(:post) do |*args|
        expect(args.first).to eq('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records')
      end
    end

    it 'retrieves record to check if exists' do
      Glare.register('example.com', 'a_destination', 'CNAME')

      expect(client).to have_received(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'example.com', type: 'CNAME'
      )
    end

    it 'sends registration data to creation endpoint when record does not exist' do
      allow(client).to receive(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'not-exist.example.com', type: 'CNAME'
      ).and_return(empty_result)

      Glare.register('not-exist.example.com', 'a_destination', 'CNAME')

      expect(client).not_to have_received(:put).
        with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

      expect(client).to have_received(:post).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        type: 'CNAME', name: 'not-exist.example.com', content: 'a_destination', proxied: false
      )
    end

    it 'sends registration data to creation endpoint when record does not exist with multiple records' do
      allow(client).to receive(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'not-exist.example.com', type: 'CNAME'
      ).and_return(empty_result)

      Glare.register('not-exist.example.com', ['a_destination', 'another_destination'].shuffle, 'CNAME')

      expect(client).not_to have_received(:put).
        with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

      expect(client).to have_received(:post).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        type: 'CNAME', name: 'not-exist.example.com', content: 'a_destination', proxied: false
      )

      expect(client).to have_received(:post).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        type: 'CNAME', name: 'not-exist.example.com', content: 'another_destination', proxied: false
      )
    end

    context 'when records exist' do
      before do
        allow(client).to receive(:get).with(
          '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
          name: 'wadus.example.com', type: 'CNAME'
        ).and_return(wadus_records)
      end

      context 'same number of records to update' do
        context 'records contents are the same' do
          it 'does not send registration data to update endpoint' do
            Glare.register('wadus.example.com', ['destination.com', 'another_destination.com'].shuffle, 'CNAME')

            expect(client).not_to have_received(:post).
              with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

            expect(client).not_to have_received(:put).with(
              '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/a1f984afe5544840505494298f54c33e',
              any_args
            )

            expect(client).not_to have_received(:put).with(
              '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/b3142498230989gsd0f88h80998908fc',
              any_args
            )
          end
        end

        context 'some records contents are the same' do
          it 'send registration data to update endpoint in different records' do
            Glare.register('wadus.example.com', ['a_destination.com', 'another_destination.com'].shuffle, 'CNAME')

            expect(client).not_to have_received(:post).
              with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

            expect(client).to have_received(:put).with(
              '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/a1f984afe5544840505494298f54c33e',
              type: 'CNAME', name: 'wadus.example.com', content: 'a_destination.com', proxied: false
            )

            expect(client).not_to have_received(:put).with(
              '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/b3142498230989gsd0f88h80998908fc',
              any_args
            )
          end
        end

        context 'all records contents are different' do
          it 'sends registration data to update endpoint' do
            Glare.register('wadus.example.com', ['a_destination.com', 'yet_another_destination.com'].shuffle, 'CNAME')

            expect(client).not_to have_received(:post).
              with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

            expect(client).to have_received(:put).with(
              any_args,
              type: 'CNAME', name: 'wadus.example.com', content: 'a_destination.com', proxied: false
            )

            expect(client).to have_received(:put).with(
              any_args,
              type: 'CNAME', name: 'wadus.example.com', content: 'yet_another_destination.com', proxied: false
            )
          end
        end

      end

      it 'updates different records and deletes extra ones' do
        Glare.register('wadus.example.com', ['a_destination.com'], 'CNAME')

        expect(client).not_to have_received(:post).
          with('/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records', any_args)

        expect(client).to have_received(:put).with(
          any_args,
          { type: 'CNAME', name: 'wadus.example.com', content: 'a_destination.com', proxied: false }
        )

        expect(client).to have_received(:delete).once
      end

      it 'updates different records and creates new ones' do
        Glare.register('wadus.example.com', ['destination.com', 'another_destination.com', 'a_third_destination.com'].shuffle, 'CNAME')

        expect(client).not_to have_received(:put).with(
          '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/a1f984afe5544840505494298f54c33e',
          any_args
        )

        expect(client).not_to have_received(:put).with(
          '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/b3142498230989gsd0f88h80998908fc',
          any_args
        )

        expect(client).to have_received(:post).with(
          '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
          type: 'CNAME', name: 'wadus.example.com', content: 'a_third_destination.com', proxied: false
        )
      end
    end
  end

  describe '.delete' do
    it 'deletes all records for a fqdn' do
      allow(client).to receive(:get).
        with('/zones', name: 'example.com').
        and_return(zone_list)

      allow(client).to receive(:get).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records',
        name: 'wadus.example.com', type: 'CNAME'
      ).and_return(wadus_records)

      Glare.deregister('wadus.example.com', 'CNAME')

      expect(client).to have_received(:delete).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/a1f984afe5544840505494298f54c33e'
      )

      expect(client).to have_received(:delete).with(
        '/zones/9de4eb694c380d79845d35cd939cc7a7/dns_records/b3142498230989gsd0f88h80998908fc'
      )
    end
  end
end
