if RUBY_VERSION < '1.9.0'
  $LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
end

require "mkmf"

# Name your extension
extension_name = 'poster_native'

# Set your target name
dir_config(extension_name)

$LDFLAGS += ' -framework CoreFoundation -framework CoreServices'

have_header(extension_name)

# Do the work
create_makefile(extension_name)
