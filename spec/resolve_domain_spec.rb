require 'cf'

describe 'Resolve domain' do
  context 'when a domain is registered' do
    let(:domain) { 'flywire.cc' }
    let(:destination) { 'peertransfer.me' }
    let(:type) { 'CNAME' }
    before do
      register_domain(domain, destination)
    end

    it 'resolves to right destination' do
      expect(resolve(domain)).to eq(destination)
    end

    def register_domain(domain, destination)
      Cf.register(domain, destination, type)
    end

    def resolve(domain)
      Cf.resolve(domain)
    end
  end
end
