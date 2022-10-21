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

      it 'resolves to right destination' do
        expect(proxied?(domain)).to eq(true)
      end
    end
  end

  def register_domain(domain, destination)
    Glare.register(domain, destination, type, proxied: true)
  end

  def deregister_domain(domain, type)
    Glare.deregister(domain, type)
  end

  def proxied?(domain)
    Glare.proxied?(domain, type)
  end
end
