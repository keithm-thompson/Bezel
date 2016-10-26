module Bezel
  class StaticAssets
    def initialize(app)
      @app = app
    end

    def call(env)
      file_path = "." + env['PATH_INFO']
      if file_path =~ (/app\/assets/)
        res = Rack::Response.new
        extension = File.extname(file_path)
          begin
            extension = ".json" if extension == ".map"
            res["Content-Type"] = Rack::Mime::MIME_TYPES[extension]
            content = File.read(file_path)
            res.write(content)
          rescue
            res.status = 404
          end
          res.finish
      else
        @app.call(env)
      end
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
