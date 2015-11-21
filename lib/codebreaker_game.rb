require 'rack'
require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require 'byebug'

class Racker
  STATUS_OK = 200
  STATUS_NOT_FOUND = 404
  NOT_FOUND_PAGE = '404'
  ROOT_PAGE = 'index'

  ROUTES = { '/' => :root, '/index' => :index, '/game' => :game, 
             '/start' => :start, '/load' => :load }

  attr_reader :message

  def self.call(env)
    new(env).process.finish
  end

  def initialize env
    @request = Rack::Request.new(env)
  end

  def process
    if ROUTES.include?(@request.path)
      send( ROUTES[@request.path] )
    else
      page_not_found
    end
  end

  def render(page, status = STATUS_OK)
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

  def root
    render(ROOT_PAGE)
  end

  def game
    @game = Codebreaker::Game.new
    @game.restore

    if @request.post?
      params = @request.params

      if @game.input_valid?(params["number"])
        @answer = @game.guess(params["number"])
        save_state
      else
        raise ArgumentError
      end
    end

    render('game')
  end

  def start
    @game = Codebreaker::Game.new
    save_state
    redirect_to :game
  end

  def load
    redirect_to :game
  end

  def page_not_found
    render(NOT_FOUND_PAGE, STATUS_NOT_FOUND)
  end
end

