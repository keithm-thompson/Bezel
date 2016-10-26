require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
module Bezel
  class ControllerBase
    attr_reader :req, :res, :params, :flash

    def self.protect_from_forgery
      @@csrf_auth = true
    end

    def initialize(req, res, route_params = {})
      @req = req
      @res = res
      @params = req.params.merge(route_params)
      @flash = Flash.new(req)
      @params['authenticity_token'] ||= SecureRandom.base64
    end

    def form_authenticity_token
      @res.set_cookie('authenticity_token',@params['authenticity_token'])
      @params['authenticity_token']
    end

    def valid_authenticity_token?(token = "")
      @params['authenticity_token'] == token
    end


    def already_built_response?
      !!@already_built_response
    end


    def redirect_to(url)
      raise 'You cannot call render more than once' if already_built_response?
      @res.status = 302
      @res['Location'] = url
      @already_built_response = true

      session.store_session(@res)
    end

    def render_content(content, content_type)
      raise 'You cannot call render more than once' if already_built_response?
      @res['Content-Type'] = content_type
      @res.write(content)
      @already_built_response = true

      session.store_session(@res)
    end

    def render(template_name)
      file_name = "app/views/"
      file_name += "#{self.class.to_s.underscore}/"
      file_name += "#{template_name}.html.erb"
      content = ERB.new(File.read(file_name)).result(binding)

      render_content(content, "text/html")
    end

    def session
      @session ||= Session.new(@req)
    end

    def invoke_action(name)
      if @@csrf_auth && @req.request_method != "GET"
        unless valid_authenticity_token?(@req.cookies['authenticity_token'])
          raise "Invalid authenticity token"
        end
      end

      send(name)
      render(name) unless already_built_response?
    end
  end
end
