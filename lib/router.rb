class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class, @action_name = controller_class, action_name
  end

  def matches?(req)
    pattern =~ req.path && http_method == req.request_method.downcase.to_sym
  end

  def run(req, res)
    raise 'no action' unless matches?(req)
    route_matches = @pattern.match(req.path)
    route_params = {}
    route_matches.names.each do |name|
      route_params[name] = route_matches[name]
    end
    controller = controller_class.new(req,res,route_params)
    controller.invoke_action(action_name)
  end
end

module Bezel
  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      self.instance_eval(&proc)
    end

    [:get, :post, :put, :delete].each do |http_method|

      define_method(http_method) do |pattern, controller_class, method|
        add_route(pattern, http_method, controller_class, method)
      end
    end

    def match(req)
      @routes.each do |route|
        return route if route.matches?(req)
      end
      nil
    end

    def run(req, res)
      route = match(req)
      return res.status = 404 unless route
      route.run(req,res)
    end
  end
end
