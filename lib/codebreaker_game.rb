require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require 'byebug'

class Racker
  def self.call(env)
    new(env).process.finish
  end

  def initialize env
    @request = Rack::Request.new(env)
  end

  def process
    status = 200

    file_path = case @request.path
    when '/' then 'index'
    else
      status = 404
      '404'
    end

    file = File.read("lib/views/#{file_path}.html.erb")
    file = ERB.new(file).result(binding)

    Rack::Response.new(file, status)
  end
end