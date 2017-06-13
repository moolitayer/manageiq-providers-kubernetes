class ManageIQ::Providers::Kubernetes::Prometheus::MessageBufferClient
  require 'faraday'

  def initialize(host, port)
    @host = host
    @port = port
  end

  def alert_url
    "http://#{@host}:#{@port}/topics/alerts"
  end

  def connect(client_options)
    ap ({
      :url     => alert_url,
      :headers => {'Authorization' => "Bearer #{client_options[:bearer]}"},
      :request => {
        :open_timeout => ::Settings.ems.ems_monitoring.alerts_collection.open_timeout.to_f_with_method, # opening a connection
        :timeout      => ::Settings.ems.ems_monitoring.alerts_collection.timeout.to_f_with_method  # waiting for response
      },
      :ssl => {
        :verify => client_options[:ssl_verify],
        :cert_store => client_options[:cert_store]
      },
      :response => :json,
      :adapter => Faraday.default_adapter,

    })
    Faraday.new(
      :url     => alert_url,
      :headers => {'Authorization' => "Bearer #{client_options[:bearer]}"},
      :request => {
        :open_timeout => ::Settings.ems.ems_monitoring.alerts_collection.open_timeout.to_f_with_method, # opening a connection
        :timeout      => ::Settings.ems.ems_monitoring.alerts_collection.timeout.to_f_with_method  # waiting for response
      },
      :ssl => {
        :verify => client_options[:ssl_verify],
        :cert_store => client_options[:cert_store]
      },
    ) do |conn|
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end
