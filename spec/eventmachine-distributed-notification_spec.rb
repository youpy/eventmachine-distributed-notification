require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'rubygems'
require 'spec_helper'
require 'eventmachine'
require 'itunes-client'

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
  Itunes::Player.play
  Itunes::Player.stop

  context 'instantiate' do
    shared_examples_for 'watch distributed notifications' do
      it 'should watch distributed notifications' do
        watcher = Watcher.new(name)

        EM.run {
          watcher.start

          Itunes::Player.play

          EM::add_timer(1) {
            Itunes::Player.stop
            EM.stop
            watcher.stop
          }
        }

        watcher.value.should_not be_nil
        watcher.user_info['Total Time'].should be_kind_of(Fixnum)
      end
    end

    context 'name is passed as a string' do
      let(:name) { 'com.apple.iTunes.playerInfo' }

      it_should_behave_like 'watch distributed notifications'
    end

    context 'name is passed as an array of strings' do
      let(:name) { ['xxx', 'com.apple.iTunes.playerInfo'] }

      it_should_behave_like 'watch distributed notifications'
    end
  end

  context 'invoked from EM.watch_distributed_notification' do
    context 'with class' do
      it 'should watch distributed notifications' do
        watcher = nil

        EM.run {
          watcher = EM.watch_distributed_notification(nil, Watcher)

          Itunes::Player.play

          EM::add_timer(1) {
            Itunes::Player.stop
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

          Itunes::Player.play

          EM::add_timer(1) {
            Itunes::Player.stop
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
