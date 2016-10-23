require 'net/http'

require 's2_netbox/version'
require 's2_netbox/helpers'

require 's2_netbox/error'
require 's2_netbox/errors/configuration_error'

require 's2_netbox/configuration'

require 's2_netbox/api_version'

module S2Netbox
  include S2Netbox::Helpers

  BASIC_ENDPOINT = '/goforms/nbapi'
  class << self
    def configure
      yield configuration

      configuration
    ensure
      configuration.validate!
    end

    def configuration
      @configuration ||= S2Netbox::Configuration.new
    end

    def clear_configuration
      @configuration = nil
    end
  end

  def self.request(url, command, session_id=nil)
    uri = URI("#{S2Netbox.configuration.controller_url}#{url}")

    req = Net::HTTP::Post.new(uri)

    req.body = "APIcommand=<NETBOX-API#{blank?(session_id) ? '' : " sessionid='#{session_id}'"}>#{command}</NETBOX-API>"
    req.content_type = 'text/xml'

    puts req.to_s

    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https' ) {|http|
      response = http.request(req)
      puts response.body
    }

    req
  end
end
