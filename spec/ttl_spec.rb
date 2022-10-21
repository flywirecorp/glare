# frozen_string_literal: true

require 'glare'

RSpec.describe 'retrieves proxied values', integration: true do
  context 'when a domain contains more than one destination' do
    let(:domain) { 'a.flywire.com.cn' }
    let(:type) { 'A' }

    before do
      register_domain(domain, destination)
    end

    after do
      deregister_domain(domain, destination)
    end

    context 'two new records' do
      let(:destination) { ['1.2.3.4', '5.6.7.8'] }

      it 'sets custom ttl' do
        records_with_correct_ttl = records(domain).all? { |r| r.ttl == 300 }
        expect(records_with_correct_ttl).to eq(true)
      end
    end
  end

  def register_domain(domain, destination)
    Glare.register(domain, destination, type, ttl: 300)
  end

  def deregister_domain(domain, type)
    Glare.deregister(domain, type)
  end

  def records(domain)
    Glare.records(domain, type)
  end
end
