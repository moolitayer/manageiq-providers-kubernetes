class ManageIQ::Providers::Kubernetes::MonitoringManager::EventCatcher::PrometheusEventMonitor
  def initialize(ems)
    @ems = ems
  end

  def start
    @collecting_events = true
  end

  def stop
    @collecting_events = false
  end

  def each_batch
    while @collecting_events
      yield fetch
    end
      # version = inventory.get_events.resourceVersion
      # watcher(version).each do |notice|
      #   yield notice
      # end
  rescue EOFError => err
    $monitoring_log.info("Monitoring connection closed #{err}")
  end

  def fetch
    unless @current_generation
      @current_generation, @current_index = last_position
    end

    # TODO: exception if no endpoint
    response = @ems.connect.get do |req|
      req.params['generationID'] = @current_generation
      req.params['fromIndex'] = @current_index
    end
    # {
    #   "generationID":"323e0863-f501-4896-b7dc-353cf863597d",
    #   "messages":[
    #   ...
    #   ]
    # }
    # TODO: raise exception unless success
    alert_list = response.body
    $monitoring_log.info("Got [#{alert_list['messages'].size}] new Alerts")
    return if alert_list['messages'].blank?
    @current_generation = alert_list["generationID"]
    @current_index = alert_list['messages'].last['index'] + 1
    events = alert_list["messages"]
    events = events.select { |alert| alert.fetch_path("data", "commonLabels", "job") == 'kubernetes-nodes'}
    events.each { |e| e['generationID'] = @current_generation }
    events
  end

  def last_position
    last_event = @ems.ems_events.last || OpenStruct.new(:full_data => {})
    last_index = last_event.full_data['index']
    [
      last_event.full_data['generationID'].to_s,
      last_index ? last_index + 1 : 0
    ]
  end
end