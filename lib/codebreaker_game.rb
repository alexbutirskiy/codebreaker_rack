require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require 'byebug'

class Racker
  def call(env)
byebug
    #[200, {"Content-Type" => "text/plain"}, ["Something happens!\n"]]
    Rack::Response.new("We use Rack::Response! Yay!")
  end
end