require 'rack'
require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require 'byebug'

class Racker
  STATUS_OK = 200
  STATUS_NOT_FOUND = 404
  NOT_FOUND_PAGE = '404'
  UNEXPECTED_BEHAVIOR_TEXT = 'Unexpected request received. \
                                Please send report to admin@codebreaker.com'
  DIGITS = Codebreaker::Settings::DIGITS_TOTAL

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

  private

  def render(page, status = STATUS_OK)
    file = File.read("lib/views/#{page}.html.erb")
    layouts = File.read("lib/views/layouts.html.erb")

    content = ERB.new(file).result(binding)
    final = ERB.new(layouts).result(binding)

    Rack::Response.new(final, status)
  end

  def redirect_to(page)
    responce = Rack::Response.new
    responce.redirect("/#{page}")
    responce
  end


###############################################################################
  def root
    render(ROOT_PAGE)
  end

  def game
    @game = Codebreaker::Game.new
    @game.restore

    if @request.post?
      params = @request.params

      if params["hint"]
        @msg = "Hint: #{@game.hint}"
        @game.save
      elsif params["number"]
        if @game.input_valid?(params["number"])
          @answer = @game.guess(params["number"])
          @game.save
          return render('win') if @game.win?
          return render('lose') if @game.lose?
        else
          @msg = "Invalid input. You should enter #{DIGITS} numbers from 1 to 6"
        end
      else
        @msg = UNEXPECTED_BEHAVIOR_TEXT
      end
    end

    render('game')
  end

  def start
    @game = Codebreaker::Game.new
    @game.save
    redirect_to :game
  end

  def load
    redirect_to :game
  end

  def page_not_found
    render(NOT_FOUND_PAGE, STATUS_NOT_FOUND)
  end
end

