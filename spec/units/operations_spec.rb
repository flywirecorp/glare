require 'glare/cf_dns_records'
require 'glare/domain/record'
require 'glare/dns_record'

RSpec.describe Glare::CfDnsRecords::Updater do
  it 'can detects new records to add' do
    current_records = Glare::CfDnsRecords.empty
    new_record = dns_record(content: '1.2.3.4')
    new_records = [new_record]
    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate
    operation = Glare::CfDnsRecords::Updater::Operation.new(new_record, :add)
    expect(operations.insertions).to match_array([operation])
  end

  it 'can detects new records to keep' do
    current_record = existing_record(content: '1.2.3.4')
    current_records = Glare::CfDnsRecords.new([current_record])
    new_record = dns_record(content: '1.2.3.4')
    new_records = [new_record]
    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate
    expect(operations.count).to be_zero
  end

  it 'can detect new records to add when there are some records' do
    current_record = existing_record(content: '1.2.3.4')
    current_records = Glare::CfDnsRecords.new([current_record])

    new_record = dns_record(content: '1.2.3.5')
    existing_record = dns_record(content: '1.2.3.4')
    new_records = [new_record, existing_record]

    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate
    operation = Glare::CfDnsRecords::Updater::Operation.new(new_record, :add)

    expect(operations.insertions).to eq([operation])
  end

  it 'can detects new records to update when there are some records' do
    current_record = existing_record(content: '1.2.3.4')
    current_records = Glare::CfDnsRecords.new([current_record])

    new_record = dns_record(content: '1.2.3.5')
    update_record = dns_record(content: '1.2.3.6')
    new_records = [update_record, new_record].shuffle

    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate
    add_operation = Glare::CfDnsRecords::Updater::Operation.new(new_records.last, :add)

    update_operation = Glare::CfDnsRecords::Updater::Operation.new(new_records.first, :update)

    expect(operations.insertions).to eq([add_operation])
    expect(operations.updates).to eq([update_operation])
  end

  it 'can detects new records to delete' do
    current_record = existing_record(content: '1.2.3.4')
    current_records = Glare::CfDnsRecords.new([current_record])

    new_records = []

    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate
    operation = Glare::CfDnsRecords::Updater::Operation.new(current_record, :delete)

    expect(operations.deletions).to match_array([operation])
  end

  it 'can detects new records to delete and update' do
    current_record = existing_record(content: '1.2.3.4')
    current_record2 = existing_record(content: '1.2.3.6')
    current_record3 = existing_record(content: '1.2.3.5')
    current_records = Glare::CfDnsRecords.new([current_record2, current_record, current_record3])

    new_record = dns_record(content: '1.2.3.8')
    update_record = dns_record(content: '1.2.3.4')
    new_records = [new_record, update_record].shuffle

    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate

    current_record2.content = '1.2.3.8'
    update_operation = Glare::CfDnsRecords::Updater::Operation.new(current_record2, :update)
    delete_operation = Glare::CfDnsRecords::Updater::Operation.new(current_record3, :delete)

    expect(operations.updates).to eq([update_operation])
    expect(operations.deletions).to eq([delete_operation])
  end

  it 'can detects new records to delete and update' do
    current_record = existing_record(content: '1.2.3.4')
    current_record2 = existing_record(content: '1.2.3.6')
    current_record3 = existing_record(content: '1.2.3.5')
    current_records = Glare::CfDnsRecords.new([current_record2, current_record, current_record3].shuffle)

    new_record = dns_record(content: '1.2.3.6')
    new_record2 = dns_record(content: '1.2.3.4')
    new_record3 = dns_record(content: '1.2.3.5')
    new_records = [new_record, new_record2, new_record3].shuffle

    operations = Glare::CfDnsRecords::Updater.new(current_records, new_records).calculate

    expect(operations.count).to be_zero
  end

  def existing_record(id: 1_234, name: 'name', type: 'A', content:)
    Glare::CfDnsRecord.new(id: id, name: name, type: type, content: content)
  end

  def dns_record(name: 'name', type: 'A', content:)
    Glare::DnsRecord.new(name: name, type: type, content: content)
  end
end
