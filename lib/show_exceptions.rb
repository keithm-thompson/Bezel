require 'erb'
module Bezel
  class ShowExceptions
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        app.call(env)
      rescue Exception => e
        render_exception(e)
      end
    end

    private

    def render_exception(e)
      response = Rack::Response.new([], 500, 'Content_Type'=> 'text/html')
      response.write(e.message)
      response.finish
    end
  end
end
