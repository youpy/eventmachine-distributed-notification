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
end
