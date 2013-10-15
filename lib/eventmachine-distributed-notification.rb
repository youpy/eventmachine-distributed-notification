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
    def initialize(names)
      names = names.kind_of?(Array) ? names : [names]
      @observers = names.map do |name|
        DistributedNotification::ObserverNative.new(name, self)
      end
    end

    def notify(name, user_info)
    end

    def start
      @observers.map(&:observe)
      @timer = EventMachine::add_periodic_timer(1) do
        @observers.map(&:run)
      end
    end

    def stop
      @observers.map(&:unobserve)
      @timer.cancel if @timer
    end
  end

  def self.watch_distributed_notification(name, handler = nil, *args, &block)
    args = [name, *args]
    klass = klass_from_handler(EventMachine::DistributedNotificationWatch, handler, *args);
    c = klass.new(*args, &block)
    block_given? and yield c
    c.start
    c
  end

  def self.post_distributed_notification(name, data)
    DistributedNotification::Poster.new.post(name, data)
  end
end
