require 'eventmachine-distributed-notification'

module Watcher
  def notify(name, user_info)
    puts user_info['data']
  end
end

EM.run {
  EM.watch_distributed_notification('client_server_example', Watcher)
}
