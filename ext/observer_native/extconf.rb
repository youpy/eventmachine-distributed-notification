require "mkmf"

# Name your extension
extension_name = 'observer_native'

# Set your target name
dir_config(extension_name)

$LDFLAGS += ' -framework CoreFoundation -framework CoreServices'

have_header(extension_name)

# Do the work
create_makefile(extension_name)
