module ManageIQ::Providers::Kubernetes::MonitoringManager::RunnerMixin
  # TODO: this should really be inside event catcher, but I can't get it to work
  extend ActiveSupport::Concern

  # This module is shared between:
  # - Kubernetes::MonitoringManager::EventCatcher
  # - Openshift::MonitoringManager::EventCatcher

  included do
    $monitoring_log.info("Included!")
  end


    def event_monitor_handle
    @event_monitor_handle ||= ManageIQ::Providers::Kubernetes::MonitoringManager::EventCatcher::PrometheusEventMonitor.new(@ems)
  end

  def reset_event_monitor_handle
    @event_monitor_handle = nil
  end

  def stop_event_monitor
    @event_monitor_handle.stop unless @event_monitor_handle.nil?
  rescue => err
    $monitoring_log.error("Event Monitor error [#{err.message}]")
    $monitoring_log.error("Error details: [#{err.details}]")
    $monitoring_log.log_backtrace(err)
  ensure
    reset_event_monitor_handle
  end

  def monitor_events
    $monitoring_log.info("Event monitor running!")
    event_monitor_handle.start
    event_monitor_running
    event_monitor_handle.each_batch do |events|
      $monitoring_log.info("got events [#{events}]")
      @queue.enq events
      # TODO: mark all events not retrieved as resolved
      sleep_poll_normal
    end

  ensure
    reset_event_monitor_handle
  end

  def queue_event(event)
    event_hash = extract_event_data(event)
    if event_hash
      $monitoring_log.info "Queuing event [#{event_hash}]"
      EmsEvent.add_queue('add', @cfg[:ems_id], event_hash)
    end
  end

  # Returns hash, or nil if event should be discarded.
  def extract_event_data(event)
    # EXAMPLE:
    #
    #     {
    #       "generationID": '3f8e1781-b755-4f6a-8855-94eb20b00dc6',
    #       "index":1,
    #       "timestamp":"2017-06-26T18:24:37.821275471+03:00",
    #       "data":{
    #         "alerts":[
    #           {
    #             "annotations":{
    #               "severity":"error",
    #               "url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    #             },
    #             "endsAt":"0001-01-01T00:00:00Z",
    #             "generatorURL":"http://dhcp-3-157.tlv.redhat.com:9090/graph?g0.expr=container_fs_usage_bytes%7Bcontainer_name%3D%22%22%2Cdevice%3D%22%2Fdev%2Fmapper%2Fvg0-lv_root%22%7D+%3E+4000000000\u0026g0.tab=0",
    #             "labels":{
    #               "alertname":"Node_high_usage_on_vg0_lvroot__info",
    #               "device":"/dev/mapper/vg0-lv_root","id":"/",
    #               "instance":"vm-48-45.eng.lab.tlv.redhat.com",
    #               "job":"kubernetes-nodes",
    #               "monitor":"codelab-monitor"
    #             },
    #             "startsAt":"2017-06-26T18:24:07.803+03:00",
    #             "status":"firing"
    #           }
    #         ],
    #         "commonAnnotations":{
    #           "severity":"error",
    #           "url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    #         },
    #         "commonLabels":{
    #           "alertname":"Node_high_usage_on_vg0_lvroot__info",
    #           "device":"/dev/mapper/vg0-lv_root","id":"/",
    #           "instance":"vm-48-45.eng.lab.tlv.redhat.com",
    #           "job":"kubernetes-nodes",
    #           "monitor":"codelab-monitor"
    #         },
    #         "externalURL":"http://dhcp-3-157.tlv.redhat.com:9093",
    #         "groupKey":"{}:{}",
    #         "groupLabels":{},
    #         "receiver":"message-buffer-wh",
    #         "status":"firing|resolved",
    #         "version":"4"
    #       }
    #     }
    event = event.dup

    annotations, labels = event["data"]["commonAnnotations"], event["data"]["commonLabels"]
    severity, event[:url] = annotations['severity'], annotations['url']

    event[:severity] = parse_severity(severity)
    event[:resolved] = event["data"]["status"] == 'resolved'
    event[:ems_ref] = genarate_incident_identifier(event, labels)

    target = find_target(labels)
    {
      :ems_id              => @cfg[:ems_id],
      :source              => 'DATAWAREHOUSE',
      :timestamp           => Time.parse(event["timestamp"]),
      :event_type          => 'datawarehouse_alert',
      :target_type         => target.class.name,
      :target_id           => target.id,
      :container_node_id   => target.id,
      :container_node_name => target.name,
      :message             => annotations['message'],
      :full_data           => event.to_h
    }
  end

  def find_target(labels)
    instance = ContainerNode.find_by(:name => labels['instance'], :ems_id => @cfg[:ems_id])
    $monitoring_log.error("Could not find alert target from labels: [#{labels}]") unless instance
    instance
  end

  def parse_severity(severity)
    MiqAlertStatus::SEVERITY_LEVELS.find { |x| x == severity.downcase} || 'error'
  end

  def genarate_incident_identifier(event, labels)
    # When event b resolves event a, they both have the same startAt.
    # Labels are added to avoid having two incidents starting at the same time.
    "#{event["data"]["alerts"][0]["startsAt"]}_#{labels.hash}"
  end
end
