require 'rack'
require './config/routes'
require_relative 'static_assets'
require_relative 'show_exceptions'
require_relative  'db_connection'

module Bezel
  class ServerConnection
    def self.start
      DBConnection.open

      asset_app = Proc.new do |env|
        req = Rack::Request.new(env)
        res = Rack::Response.new
        ROUTER.run(req, res)
        res.finish
      end

      app = Rack::Builder.new do
        use Bezel::ShowExceptions
        use Bezel::StaticAssets
        run asset_app
      end
      run app
    end
  end
end
