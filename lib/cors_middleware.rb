class CorsMiddleware
  ALLOWED_METHODS = %w[GET POST PATCH PUT DELETE OPTIONS HEAD].freeze
  ALLOWED_HEADERS = %w[authorization content-type accept x-csrf-token].freeze

  def initialize(app)
    @app = app
    @allowed_origins = ENV.fetch("FRONTEND_ORIGINS", "http://localhost:3001")
                        .split(",")
                        .map(&:strip)
                        .reject(&:empty?)
  end

  def call(env)
    request = Rack::Request.new(env)
    origin = request.get_header("HTTP_ORIGIN")
    return @app.call(env) unless request.path.start_with?("/api/") && @allowed_origins.include?(origin)

    if request.options? && request.get_header("HTTP_ACCESS_CONTROL_REQUEST_METHOD")
      return preflight_response(env) if valid_preflight?(request)
    end

    status, headers, body = @app.call(env)
    headers["Access-Control-Allow-Origin"] = origin
    headers["Vary"] = [ headers["Vary"], "Origin" ].compact.join(", ")
    [ status, headers, body ]
  end

  private

  def valid_preflight?(request)
    method = request.get_header("HTTP_ACCESS_CONTROL_REQUEST_METHOD").upcase
    headers = request.get_header("HTTP_ACCESS_CONTROL_REQUEST_HEADERS").to_s
                 .split(",").map { |header| header.strip.downcase }

    ALLOWED_METHODS.include?(method) && (headers - ALLOWED_HEADERS).empty?
  end

  def preflight_response(env)
    origin = env["HTTP_ORIGIN"]
    [ 204, {
      "Access-Control-Allow-Origin" => origin,
      "Access-Control-Allow-Methods" => ALLOWED_METHODS.join(", "),
      "Access-Control-Allow-Headers" => ALLOWED_HEADERS.join(", "),
      "Access-Control-Max-Age" => "600",
      "Vary" => "Origin, Access-Control-Request-Method, Access-Control-Request-Headers"
    }, [] ]
  end
end
