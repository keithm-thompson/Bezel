module Bezel
end

require_relative 'bezelrecord_base/bezelrecord_base'
require_relative 'controller_base'

Dir.glob('./app/models/*.rb') { |file| require file }
Dir.glob('./app/controllers/*.rb') { |file| require file }

require './db/seeds'

require_relative 'db_connection'
require_relative 'router'
require_relative 'server_connection'
require_relative 'session'
require_relative 'flash'
require_relative 'static_assets'
