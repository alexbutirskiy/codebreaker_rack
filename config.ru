require './lib/codebreaker_game'
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'lib/assets/css'
  environment.append_path 'lib/assets/js'
  run environment
end

run Racker