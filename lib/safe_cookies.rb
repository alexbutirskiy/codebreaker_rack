require 'openssl'
require 'byebug'

class SafeCookies
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
byebug
    [status, headers, body]
  end
end