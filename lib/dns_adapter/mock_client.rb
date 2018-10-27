require 'dns_adapter/error'

module DNSAdapter
  # A mock client for use in tests.
  class MockClient
    def initialize(zone_data)
      @zone_data = {}
      zone_data.each do |k, v|
        @zone_data[k.downcase] = v.dup
      end
    end

    %w[A AAAA MX NS CNAME TXT SPF].each do |rtype|
      define_method("fetch_#{rtype.downcase}_records") do |domain|
        fetch_records(domain, rtype)
      end
    end

    def fetch_ptr_records(arpa_address)
      fetch_records(arpa_address, 'PTR')
    end

    def timeouts=(timeouts)
      # Deliberate NOOP
    end

    def fetch_records(domain, type)
      records = raw_records(domain, type)
      if records.empty?
        check_for_timeout(domain)
      else
        formatted_records(records, type)
      end
    end

    def raw_records(domain, type)
      record_set = find_records_for_domain(domain)
      return [] if record_set.empty?

      follow_cname(record_set, type) || records_for_type(record_set, type)
    end

    def follow_cname(record_set, type)
      return nil if type == 'CNAME' # Never follow CNAME for a CNAME query

      cname_record = formatted_records(records_for_type(record_set, 'CNAME'), 'CNAME').first
      cname_target = cname_record.try(:[], :name)
      cname_target.present? ? raw_records(cname_target, type) : nil
    end

    private

    def normalize_domain(domain)
      return if domain.blank?

      domain = domain[0...-1] if domain[domain.length - 1] == '.'
      domain.downcase
    end

    def find_records_for_domain(domain)
      return [] if domain.blank?

      @zone_data[normalize_domain(domain)] || []
    end

    def records_for_type(record_set, type)
      record_set.select do |r|
        r.is_a?(Hash) && r[type] && r[type] != 'NONE'
      end
    end

    TIMEOUT = 'TIMEOUT'.freeze
    def check_for_timeout(domain)
      record_set = find_records_for_domain(domain)
      return [] if record_set.select { |r| r == TIMEOUT }.empty?

      raise DNSAdapter::TimeoutError
    end

    RECORD_TYPE_TO_ATTR_NAME_MAP = {
      'A' => :address,
      'AAAA' => :address,
      'MX' => :exchange,
      'PTR' => :name,
      'NS' => :name,
      'CNAME' => :name,
      'SPF' => :text,
      'TXT' => :text
    }.freeze

    def formatted_records(records, type)
      records.map do |r|
        val = r[type]
        raise DNSAdapter::TimeoutError if val == TIMEOUT

        value_to_hash(val, type).merge(type: type)
      end
    end

    def value_to_hash(value, type)
      if type == 'MX' && value.is_a?(Array)
        mx_hash(value)
      elsif %w[TXT SPF].include?(type) && value.is_a?(Array)
        { text: value.join('') }
      else
        { RECORD_TYPE_TO_ATTR_NAME_MAP[type] => value }
      end
    end

    def mx_hash(value)
      if value.size > 1
        { preference: value.first, exchange: value.last }
      else
        { exchange: value.last }
      end
    end
  end
end
