# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
tasks = Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "eventmachine-distributed-notification"
  gem.homepage = "http://github.com/youpy/eventmachine-distributed-notification"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "youpy@buycheapviagraonlinenow.com"
  gem.authors = ["youpy"]
  gem.extensions = FileList["ext/**/extconf.rb"]
end

# rule to build the extension: this says
# that the extension should be rebuilt
# after any change to the files in ext
ext_name = 'observer_native'
file "lib/#{ext_name}.bundle" =>
  Dir.glob("ext/#{ext_name}/*{.rb,.m}") do
  Dir.chdir("ext/#{ext_name}") do
    # this does essentially the same thing
    # as what RubyGems does
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/#{ext_name}/#{ext_name}.bundle", "lib/"
end

task :spec => "lib/#{ext_name}.bundle"

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
