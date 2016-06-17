require 'cf'

RSpec.describe 'Resolve domain' do
  context 'when a domain is registered' do
    let(:domain) { 'cname.flywire.cc' }
    let(:destination) { ['peertransfer.me'] }
    let(:type) { 'CNAME' }
    before do
      register_domain(domain, destination)
    end

    it 'resolves to right destination' do
      expect(resolve(domain)).to eq(destination)
    end
  end

  context 'when a domain contains more than one destination' do
    let(:domain) { 'a.flywire.cc' }
    let(:type) { 'A' }
    before do
      register_domain(domain, destination)
    end

    context 'two new records' do
      let(:destination) { ['1.2.3.4', '5.6.7.8'] }

      it 'resolves to right destination' do
        expect(resolve(domain)).to eq(destination)
      end
    end

    context 'deletes one record' do
      let(:destination) { ['1.2.3.9'] }

      it 'resolves to right destination' do
        expect(resolve(domain)).to eq(destination)
      end
    end

    context 'adds one record' do
      let(:destination) { ['1.2.3.5', '6.7.8.9'] }

      it 'resolves to right destination' do
        expect(resolve(domain)).to eq(destination)
      end
    end
  end

  def register_domain(domain, destination)
    Cf.register(domain, destination, type)
  end

  def resolve(domain)
    Cf.resolve(domain, type)
  end
end
