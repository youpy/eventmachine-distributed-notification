require 'eventmachine'
require 'observer_native'
require 'poster_native'

module EventMachine
  module DistributedNotification
    class Poster
      def initialize
        @poster = PosterNative.new
      end

      def post(name, data)
        @poster.post(name, data)
      end
    end
  end

  class DistributedNotificationWatch
    def initialize(name)
      @observer = DistributedNotification::ObserverNative.new(name, self)
    end

    def notify(name, user_info)
    end

    def start
      @observer.observe
      @timer = EventMachine::add_periodic_timer(1) do
        @observer.run
      end
    end

    def stop
      @observer.unobserve
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

  def self.post_distributed_notification(name, data)
    DistributedNotification::Poster.new.post(name, data)
  end
end
