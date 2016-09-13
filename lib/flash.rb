require 'json'

class Flash
  def initialize(req)
    if req.cookies['_rails_lite_app_flash']
      @flash = JSON.parse(req.cookies['_rails_lite_app_flash'])
    else
      @flash = {}
    end
    @flash_now = {}
  end

  def []=(key,val)
    @flash[key] = val
  end

  def [](key)
    return @flash_now[key] if @flash_now[key]
    @flash[key.to_s]
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', value: @flash.to_json, path: '/')
  end

  def now
    @flash_now
  end
end
