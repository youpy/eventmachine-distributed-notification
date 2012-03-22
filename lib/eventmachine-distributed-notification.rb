require 'eventmachine'
require 'observer_native'

module EventMachine
  class DistributedNotificationWatch
    def initialize(name)
      @observer = DistributedNotification::ObserverNative.new(name, self)
    end

    def notify(name, user_info)
    end

    def start
      @timer = EventMachine::add_periodic_timer(1) do
        @observer.run
      end
    end

    def stop
      @timer.cancel if @timer
    end
  end

  def self.watch_distributed_notification(name, handler = nil, *args, &block)
    args = [name, *args]
    klass = klass_from_handler(EventMachine::DistributedNotificationWatch, handler, *args);
    c = klass.new(*args, &block)
    c.start
    c
  end
end
