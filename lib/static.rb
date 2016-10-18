class Static
  def initialize(app)
    @app = app
  end

  def call(env)
    file_path = "." + env['PATH_INFO']
    res = Rack::Response.new
    extension = /\.(\w*$)/.match(file_path)[1]

    case extension
      when "txt"
        res['Content-Type'] = "text/plain"
      when "jpg"
        res['Content-Type'] = "image/jpeg"
      when "zip"
        res['Content-Type'] = "application/zip"
      when "png"
        res['Content-Type'] = "image/png"
    end

    begin
      content = File.read(file_path)
      res.write(content)
    rescue
      res.status = 404
    end

    res.finish
  end
end
