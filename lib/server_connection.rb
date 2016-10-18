require 'rack'
require './config/routes'

module Bezel
  class ServerConnection
    def self.start
      app = proc do |env|
        req = Rack::Request.new(env)
        res = Rack::Response.new
        ROUTER.run(req, res)
        res.finish
      end

      Rack::Server.start(
        app: app,
        Port: 3000
      )
    end
  end
end
