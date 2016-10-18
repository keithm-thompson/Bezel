require 'json'

module Bezel
  class Session
    def initialize(req)
      if req.cookies['_']
        @cookie =  JSON.parse(req.cookies['_bezel'])
      else
        @cookie = {}
      end
    end

    def [](key)
      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    def store_session(res)
      json_cookie = @cookie.to_json
      res.set_cookie('_bezel', value: json_cookie, path: '/' )
    end
  end
end
