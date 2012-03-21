require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
require 'spec_helper'
require 'eventmachine'
require 'appscript'

class Watcher < EM::DistributedNotificationWatch
  attr_accessor :value

  def notify(name, user_info)
    @value = name
    p user_info
  end
end

describe EventMachine::DistributedNotificationWatch do
  itunes = Appscript.app('iTunes')
  itunes.run
  itunes.stop

  it 'should observe distributed notifications' do
    watcher = Watcher.new(nil)
    EM.run {
      watcher.start

      itunes.playlists["Music"].tracks[1].play

      EM::add_timer(1) {
        itunes.stop
        EM.stop
      }
    }

    watcher.value.should eql('com.apple.iTunes.playerInfo')
  end
end
