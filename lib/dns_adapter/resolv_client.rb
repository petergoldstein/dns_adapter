require 'resolv'
require 'resolv/dns/resource/in/spf'

module DNSAdapter
  # An adapter client for the internal Resolv DNS client.
  class ResolvClient
    def fetch_a_records(domain)
      fetch_a_type_records(domain, 'A')
    end

    def fetch_aaaa_records(domain)
      fetch_a_type_records(domain, 'AAAA')
    end

    def fetch_mx_records(domain)
      fetch_records(domain, 'MX') do |record|
        {
          type: 'MX',
          exchange: record.exchange.to_s,
          preference: record.preference,
          ttl: record.ttl
        }
      end
    end

    def fetch_ptr_records(arpa_address)
      fetch_name_records(arpa_address, 'PTR')
    end

    def fetch_txt_records(domain)
      fetch_txt_type_records(domain, 'TXT')
    end

    def fetch_spf_records(domain)
      fetch_txt_type_records(domain, 'SPF')
    end

    def fetch_ns_records(domain)
      fetch_name_records(domain, 'NS')
    end

    def fetch_cname_records(domain)
      fetch_name_records(domain, 'CNAME')
    end

    def timeouts=(timeouts)
      dns_resolver.timeouts = timeouts
    end

    SUPPORTED_RR_TYPES = %w[A AAAA MX PTR TXT SPF NS CNAME].freeze
    def self.type_class(rr_type)
      raise ArgumentError, "Unknown RR type: #{rr_type}" unless SUPPORTED_RR_TYPES.include?(rr_type)

      Resolv::DNS::Resource::IN.const_get(rr_type)
    end

    private

    def fetch_a_type_records(domain, type)
      fetch_records(domain, type) do |record|
        {
          type: type,
          address: record.address.to_s,
          ttl: record.ttl
        }
      end
    end

    def fetch_txt_type_records(domain, type)
      fetch_records(domain, type) do |record|
        {
          type: type,
          # Use strings.join('') to avoid JRuby issue where
          # data only returns the first string
          text: record.strings.join('').encode('US-ASCII', invalid: :replace,
                                                           undef: :replace,
                                                           replace: '?'),
          ttl: record.ttl
        }
      end
    end

    def fetch_name_records(domain, type)
      fetch_records(domain, type) do |record|
        {
          type: type,
          name: record.name.to_s,
          ttl: record.ttl
        }
      end
    end

    def fetch_records(domain, type, &block)
      records = dns_lookup(domain, type)
      records.map(&block)
    end

    TRAILING_DOT_REGEXP = /\.\z/.freeze
    def normalize_domain(domain)
      (domain.sub(TRAILING_DOT_REGEXP, '') || domain).downcase
    end

    def dns_lookup(domain, rr_type)
      domain = normalize_domain(domain)
      resources = getresources(domain, rr_type)

      unless resources
        raise DNSAdapter::Error,
              "Unknown error on DNS '#{rr_type}' lookup of '#{domain}'"
      end

      resources
    end

    def getresources(domain, rr_type)
      rr_class = self.class.type_class(rr_type)
      dns_resolver.getresources(domain, rr_class)
    rescue Resolv::ResolvTimeout
      raise DNSAdapter::TimeoutError,
            "Time-out on DNS '#{rr_type}' lookup of '#{domain}'"
    rescue Resolv::ResolvError
      raise DNSAdapter::Error, "Error on DNS lookup of '#{domain}'"
    end

    def dns_resolver
      @dns_resolver ||= Resolv::DNS.new
    end
  end
end
