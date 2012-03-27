require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
require 'spec_helper'
require 'eventmachine'
require 'appscript'

class Watcher < EM::DistributedNotificationWatch
  attr_accessor :value, :user_info

  def notify(name, user_info)
    @value = name
    @user_info = user_info
  end
end

describe EventMachine::DistributedNotification::Poster do
  it 'should post distributed notifications' do
    watcher = Watcher.new('xxx')

    EM.run {
      watcher.start

      EM::add_timer(1) {
        EM::post_distributed_notification('xxx', 'yyy')
        EM.stop
        watcher.stop
      }
    }

    watcher.value.should_not be_nil
  end
end

describe EventMachine::DistributedNotificationWatch do
  itunes = Appscript.app('iTunes')
  itunes.run
  itunes.stop

  context 'instantiate' do
    it 'should watch distributed notifications' do
      watcher = Watcher.new('com.apple.iTunes.playerInfo')

      EM.run {
        watcher.start

        itunes.playlists["Music"].tracks[1].play

        EM::add_timer(1) {
          itunes.stop
          EM.stop
          watcher.stop
        }
      }

      watcher.value.should_not be_nil
      watcher.user_info['Total Time'].should be_kind_of(Fixnum)
    end
  end

  context 'invoked from EM.watch_distributed_notification' do
    context 'with class' do
      it 'should watch distributed notifications' do
        watcher = nil

        EM.run {
          watcher = EM.watch_distributed_notification(nil, Watcher)

          itunes.playlists["Music"].tracks[1].play

          EM::add_timer(1) {
            itunes.stop
            EM.stop
            watcher.stop
          }
        }

        watcher.value.should_not be_nil
      end
    end

    context 'with block' do
      it 'should watch distributed notifications' do
        value = nil

        EM.run {
          watcher = EM.watch_distributed_notification(nil) do |c|
            (class << c; self; end).send(:define_method, :notify) do |name, info|
              value = info
            end
          end

          itunes.playlists["Music"].tracks[1].play

          EM::add_timer(1) {
            itunes.stop
            EM.stop
            watcher.stop
          }
        }

        value.should_not be_nil
        value['Total Time'].should be_kind_of(Fixnum)
      end
    end
  end
end
