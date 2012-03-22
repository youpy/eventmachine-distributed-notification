require 'eventmachine-distributed-notification'

EM.run {
  EM::add_periodic_timer(1) do
    EM.post_distributed_notification('client_server_example', Time.now.to_s)
  end
}
