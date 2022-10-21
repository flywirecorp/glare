# frozen_string_literal: true

require 'glare'

RSpec.describe 'delete domain', integration: true do
  context 'when a domain is registered' do
    let(:domain) { 'a.flywire.com.cn' }
    let(:type) { 'A' }
    let(:destination) { ['1.2.3.5', '6.7.8.9'] }
    before do
      register_domain(domain, destination)
    end

    it 'deletes all records with given type' do
      expect(resolve(domain)).to match_array(destination)
      delete(domain)
      expect(resolve(domain)).to eq([])
    end
  end

  def delete(domain)
    Glare.deregister(domain, type)
  end

  def resolve(domain)
    Glare.resolve(domain, type)
  end

  def register_domain(domain, destination)
    Glare.register(domain, destination, type)
  end
end
