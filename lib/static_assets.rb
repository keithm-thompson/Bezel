module Bezel
  class StaticAssets
    def initialize(app)
      @app = app
    end

    def call(env)
      file_path = "." + env['PATH_INFO']
      res = Rack::Response.new
      extension = /\.(\w*$)/.match(file_path)[1]
      begin
        res['Content-Type'] = set_content_type(extension)
        content = File.read(file_path)
        res.write(content)
      rescue
        res.status = 404
      end

      res.finish
    end
  end

  private
  def set_content_type(extension)
    case extension
      when "txt"
         "text/plain"
      when "jpg"
        "image/jpeg"
      when "zip"
        "application/zip"
      when "png"
        "image/png"
      else
        raise 'extension not supported'
    end
  end
end
