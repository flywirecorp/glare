require 'glare'

RSpec.describe 'Resolve domain', integration: true do
  context 'when a domain is registered' do
    let(:domain) { 'cname.flywire.com.cn' }
    let(:destination) { ['peertransfer.me'] }
    let(:type) { 'CNAME' }

    it 'resolves to right destination' do
      register_domain(domain, destination)

      expect(resolve(domain)).to eq(destination)
    end

    it 'raises an exception if domain does not exist in account' do
      register_domain(domain, destination)

      expect do
        resolve('error.ojete.cc')
      end.to raise_error(Glare::Errors::NotExistingZoneError)
    end

    it 'raises an exception if api returns error' do
      expect do
        register_domain('error.flywire.com.cn', '1.1.1.1')
      end.to raise_error(Glare::Errors::ApiError)
    end
  end

  context 'when a domain contains more than one destination' do
    let(:domain) { 'a.flywire.com.cn' }
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
    Glare.register(domain, destination, type)
  end

  def resolve(domain)
    Glare.resolve(domain, type)
  end
end
