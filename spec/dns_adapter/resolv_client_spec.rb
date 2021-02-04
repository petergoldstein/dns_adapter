require 'spec_helper'

describe DNSAdapter::ResolvClient do
  subject(:client) { described_class.new }

  let(:mock_resolver) { instance_double(Resolv::DNS) }

  describe '#fetch_a_records' do
    let(:first_a_addr) { Resolv::IPv4.new([127, 0, 0, 1].pack('CCCC')) }
    let(:first_a_record) { Resolv::DNS::Resource::IN::A.new(first_a_addr) }
    let(:second_a_addr) { Resolv::IPv4.new([192, 168, 8, 14].pack('CCCC')) }
    let(:second_a_record) { Resolv::DNS::Resource::IN::A.new(second_a_addr) }
    let(:record_list) { [first_a_record, second_a_record] }
    let(:domain) { 'example.com' }
    let(:domain_with_trailing) { "#{domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::A).and_return(record_list)
      results = client.fetch_a_records(domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'A' })
      expect(results.map { |x| x[:address] })
        .to eq(record_list.map(&:address).map(&:to_s))
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::A).and_return(record_list)
      results = client.fetch_a_records(domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'A' })
      expect(results.map { |x| x[:address] })
        .to eq(record_list.map(&:address).map(&:to_s))
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::A)
        .and_raise(Resolv::ResolvError)
      expect do
        client.fetch_a_records(domain_with_trailing)
      end.to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::A)
        .and_raise(Resolv::ResolvTimeout)
      expect do
        client.fetch_a_records(domain_with_trailing)
      end.to raise_error(DNSAdapter::TimeoutError)
    end

    it 'maps the nil responses to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::A)
        .and_return(nil)
      expect do
        client.fetch_a_records(domain_with_trailing)
      end.to raise_error(DNSAdapter::Error)
    end
  end

  describe '#fetch_aaaa_records' do
    let(:first_aaaa_addr) do
      Resolv::IPv6.create('FE80:10:1:1:202:B3FF:FE1E:8329')
    end
    let(:first_aaaa_record) do
      Resolv::DNS::Resource::IN::AAAA.new(first_aaaa_addr)
    end
    let(:second_aaaa_addr) do
      Resolv::IPv6.create('AB61:10:111:891:4202:B3FF:FE1E:7329')
    end
    let(:second_aaaa_record) do
      Resolv::DNS::Resource::IN::AAAA.new(second_aaaa_addr)
    end
    let(:record_list) { [first_aaaa_record, second_aaaa_record] }
    let(:domain) { 'example.com' }
    let(:domain_with_trailing) { "#{domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::AAAA).and_return(record_list)
      results = client.fetch_aaaa_records(domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'AAAA' })
      expect(results.map { |x| x[:address] })
        .to eq(record_list.map(&:address).map(&:to_s))
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::AAAA).and_return(record_list)
      results = client.fetch_aaaa_records(domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'AAAA' })
      expect(results.map { |x| x[:address] })
        .to eq(record_list.map(&:address).map(&:to_s))
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::AAAA)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_aaaa_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::AAAA)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_aaaa_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_mx_records' do
    let(:first_mx_name) do
      Resolv::DNS::Name.create('alt1.aspmx.l.google.com.')
    end
    let(:first_mx_record) do
      Resolv::DNS::Resource::IN::MX.new(20, first_mx_name)
    end
    let(:second_mx_name) do
      Resolv::DNS::Name.create('aspmx.l.google.com')
    end
    let(:second_mx_record) do
      Resolv::DNS::Resource::IN::MX.new(10, second_mx_name)
    end
    let(:record_list) { [first_mx_record, second_mx_record] }
    let(:domain) { 'example.com' }
    let(:domain_with_trailing) { "#{domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::MX).and_return(record_list)
      results = client.fetch_mx_records(domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'MX' })
      expect(results.map { |x| x[:exchange] })
        .to eq(record_list.map(&:exchange).map(&:to_s))
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::MX).and_return(record_list)
      results = client.fetch_mx_records(domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'MX' })
      expect(results.map { |x| x[:exchange] })
        .to eq(record_list.map(&:exchange).map(&:to_s))
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::MX)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_mx_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::MX)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_mx_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_txt_records' do
    let(:first_txt_string) { SecureRandom.hex(10) }
    let(:first_txt_record) do
      Resolv::DNS::Resource::IN::TXT.new(first_txt_string)
    end
    let(:second_txt_string) { SecureRandom.hex(10) }
    let(:second_txt_string_array) do
      [SecureRandom.hex(10), SecureRandom.hex(10)]
    end
    let(:second_txt_record) do
      Resolv::DNS::Resource::IN::TXT.new(second_txt_string,
                                         second_txt_string_array)
    end
    let(:record_list) { [first_txt_record, second_txt_record] }
    let(:domain) { 'example.com' }
    let(:domain_with_trailing) { "#{domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::TXT)
        .and_return(record_list)
      results = client.fetch_txt_records(domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'TXT' })
      expect(results.map { |x| x[:text] }).to eq(
        [first_txt_string,
         ([second_txt_string] + second_txt_string_array).join]
      )
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::TXT)
        .and_return(record_list)
      results = client.fetch_txt_records(domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'TXT' })
      expect(results.map { |x| x[:text] }).to eq(
        [first_txt_string,
         ([second_txt_string] + second_txt_string_array).join]
      )
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::TXT)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_txt_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::TXT)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_txt_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_spf_records' do
    let(:first_spf_string) { SecureRandom.hex(10) }
    let(:first_spf_record) do
      Resolv::DNS::Resource::IN::TXT.new(first_spf_string)
    end
    let(:second_spf_string) { SecureRandom.hex(10) }
    let(:second_spf_string_array) do
      [SecureRandom.hex(10), SecureRandom.hex(10)]
    end
    let(:second_spf_record) do
      Resolv::DNS::Resource::IN::SPF.new(second_spf_string,
                                         second_spf_string_array)
    end
    let(:record_list) { [first_spf_record, second_spf_record] }
    let(:domain) { 'example.com' }
    let(:domain_with_trailing) { "#{domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::SPF)
        .and_return(record_list)
      results = client.fetch_spf_records(domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'SPF' })
      expect(results.map { |x| x[:text] }).to eq(
        [first_spf_string,
         ([second_spf_string] + second_spf_string_array).join]
      )
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::SPF)
        .and_return(record_list)
      results = client.fetch_spf_records(domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'SPF' })
      expect(results.map { |x| x[:text] }).to eq(
        [first_spf_string,
         ([second_spf_string] + second_spf_string_array).join]
      )
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::SPF)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_spf_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(domain, Resolv::DNS::Resource::IN::SPF)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_spf_records(domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_ptr_records' do
    let(:first_ptr_name) { SecureRandom.hex(10) }
    let(:first_ptr_record) do
      Resolv::DNS::Resource::IN::PTR.new(first_ptr_name)
    end
    let(:record_list) { [first_ptr_record] }
    let(:arpa_domain) { '126.18.67.80.in-addr.arpa' }
    let(:arpa_domain_with_trailing) { "#{arpa_domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(arpa_domain, Resolv::DNS::Resource::IN::PTR)
        .and_return(record_list)
      results = client.fetch_ptr_records(arpa_domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'PTR' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_ptr_name]
      )
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(arpa_domain, Resolv::DNS::Resource::IN::PTR)
        .and_return(record_list)
      results = client.fetch_ptr_records(arpa_domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'PTR' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_ptr_name]
      )
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(arpa_domain, Resolv::DNS::Resource::IN::PTR)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_ptr_records(arpa_domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(arpa_domain, Resolv::DNS::Resource::IN::PTR)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_ptr_records(arpa_domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_ns_records' do
    let(:first_ns_name) { SecureRandom.hex(10) }
    let(:first_ns_record) do
      Resolv::DNS::Resource::IN::NS.new(first_ns_name)
    end
    let(:record_list) { [first_ns_record] }
    let(:ns_domain) { 'example.com' }
    let(:ns_domain_with_trailing) { "#{ns_domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(ns_domain, Resolv::DNS::Resource::IN::NS)
        .and_return(record_list)
      results = client.fetch_ns_records(ns_domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'NS' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_ns_name]
      )
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(ns_domain, Resolv::DNS::Resource::IN::NS)
        .and_return(record_list)
      results = client.fetch_ns_records(ns_domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'NS' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_ns_name]
      )
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(ns_domain, Resolv::DNS::Resource::IN::NS)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_ns_records(ns_domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(ns_domain, Resolv::DNS::Resource::IN::NS)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_ns_records(ns_domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#fetch_cname_records' do
    let(:first_cname_name) { SecureRandom.hex(10) }
    let(:first_cname_record) do
      Resolv::DNS::Resource::IN::CNAME.new(first_cname_name)
    end
    let(:record_list) { [first_cname_record] }
    let(:cname_domain) { 'example.com' }
    let(:cname_domain_with_trailing) { "#{cname_domain}." }

    it 'maps the Resolv classes to a set of hashes' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(cname_domain, Resolv::DNS::Resource::IN::CNAME)
        .and_return(record_list)
      results = client.fetch_cname_records(cname_domain)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'CNAME' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_cname_name]
      )
    end

    it 'maps when the domain has a trailing dot' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(cname_domain, Resolv::DNS::Resource::IN::CNAME)
        .and_return(record_list)
      results = client.fetch_cname_records(cname_domain_with_trailing)
      expect(results.size).to eq(record_list.length)
      expect(results.map { |x| x[:type] })
        .to eq(Array.new(record_list.length) { 'CNAME' })
      expect(results.map { |x| x[:name] }).to eq(
        [first_cname_name]
      )
    end

    it 'maps the Resolv errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(cname_domain, Resolv::DNS::Resource::IN::CNAME)
        .and_raise(Resolv::ResolvError)
      expect { client.fetch_cname_records(cname_domain_with_trailing) }
        .to raise_error(DNSAdapter::Error)
    end

    it 'maps the Resolv timeout errors to Coppertone errors' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:getresources)
        .with(cname_domain, Resolv::DNS::Resource::IN::CNAME)
        .and_raise(Resolv::ResolvTimeout)
      expect { client.fetch_cname_records(cname_domain_with_trailing) }
        .to raise_error(DNSAdapter::TimeoutError)
    end
  end

  describe '#timeouts=' do
    let(:timeout_val) { 5 }

    it 'delegates timeouts=' do
      expect(Resolv::DNS).to receive(:new).and_return(mock_resolver)
      expect(mock_resolver).to receive(:timeouts=).with(timeout_val)
      expect { client.timeouts = timeout_val }.not_to raise_error
    end
  end
end
