module ManageIQ::Providers::Kubernetes::MonitoringManagerMixin
  extend ActiveSupport::Concern
  ENDPOINT_ROLE = 'prometheus_alerts'.freeze
  DEFAULT_PORT = 9093
  included do
    default_value_for :port do |provider|
      provider.port || DEFAULT_PORT
    end
  end

  def authentications
    parent_manager.authentications.where(:authtype => ENDPOINT_ROLE)
  end

  def connection_configurations
    parent_manager.connection_configurations[ENDPOINT_ROLE] || []
  end

  def endpoints
    parent_manager.endpoints.where(:role => ENDPOINT_ROLE)
  end

  def default_endpoint
    endpoints.first
  end

  def supports_port?
    true
  end

  # Authentication related methods, see AuthenticationMixin
  def authentications_to_validate
    [ENDPOINT_ROLE]
  end

  def required_credential_fields(_type)
    [:auth_key]
  end

  def verify_credentials(auth_type = nil, options = {})
    with_provider_connection(options.merge(:auth_type => auth_type)) do |conn|
      # TODO: move to a client method, once we have one
      conn.get.body.has_key?('generationID')
    end
  # TODO: distinguish credential validation error
  rescue Faraday::ClientError => err
    raise MiqException::MiqUnreachableError, err.message, err.backtrace
  end

  def connect(options)
    ManageIQ::Providers::Kubernetes::MonitoringManagerMixin.raw_connect(
      options[:hostname] || hostname,
      options[:port] || port,
      {
        :bearer     => options[:bearer] || authentication_token(options[:auth_type] || 'bearer'),
        :ssl_verify => options[:ssl_verify] || ManageIQ::Providers::Kubernetes::MonitoringManagerMixin.ssl_verify,
        :cert_store => options[:cert_store] || ssl_cert_store
      }
    )
  end

  def ssl_cert_store
    # Given missing (nil) endpoint, return nil meaning use system CA bundle
    default_endpoint.try(:ssl_cert_store)
  end

  def self.ssl_verify
    # TODO: always verify SSL
    false
  end

  def self.raw_connect(hostname, port, options)
    ManageIQ::Providers::Kubernetes::Prometheus::MessageBufferClient.new(hostname, port).connect(options)
  end
end
