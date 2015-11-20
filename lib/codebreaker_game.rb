require 'rack'
require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require 'byebug'

class Racker
  include Codebreaker
  def self.call(env)
    new(env).process.finish
  end

  def initialize env
    @request = Rack::Request.new(env)
  end

  def process
    status = 200

    case @request.path
    when '/'
      responce = render('index')
    when '/game'
      @game = Game.new
      @game.restore
      if @request.post?
        params = @request.params
         if @game.input_valid?(params["number"])
          @answer = @game.guess(params["number"])
          save_state
        else
          raise ArgumentError
        end
      else
      end
      responce = render('game')
    when '/start'
      @game = Game.new
      save_state
      redirect_to :game
    when '/load'
      redirect_to :game
    else
      responce = render('404', 404)
    end

    responce
  end

  def render(page, status=200)
      file = File.read("lib/views/#{page}.html.erb")
      file = ERB.new(file).result(binding)
      responce = Rack::Response.new(file, status)
  end

  def redirect_to(page)
    responce = Rack::Response.new
    responce.redirect("/#{page}")
    responce
  end

  def save_state
    @game.save(except: :rng)
  end
end

