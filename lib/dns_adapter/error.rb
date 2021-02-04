module DNSAdapter
  class Error < ::StandardError; end

  class TimeoutError < Error; end

  class NXDomainError < Error; end
end
