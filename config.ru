require './lib/codebreaker_game'
require './lib/secure_cookies'
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'lib/assets/css'
  environment.append_path 'lib/assets/js'
  run environment
end

use SecureCookies
run Racker