require './lib/codebreaker_game'
require './lib/safe_cookies'
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'lib/assets/css'
  environment.append_path 'lib/assets/js'
  run environment
end

use SafeCookies
run Racker