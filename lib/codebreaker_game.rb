require 'rack'
require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require_relative './user'
require 'byebug'

class Racker
  STATUS_OK = 200
  STATUS_NOT_FOUND = 404
  NOT_FOUND_PAGE = '404'
  UNEXPECTED_BEHAVIOR_TEXT = 'Unexpected request received. \
                                Please send report to admin@codebreaker.com'
  DIGITS = Codebreaker::Settings::DIGITS_TOTAL

  ROOT_PAGE = 'index'
  ROUTES = { '/' => :index, '/index' => :index, '/game' => :game, 
             '/start' => :start, '/load' => :load, '/register' => :register,
             '/login' => :login, '/logout' => :logout}

  PWD_MIN_LENGHT = 4
  USER_NAME_REGEX = /^[a-zA-Z0-9_@.]+$/
  WRONG_USER_NAME_MSG = "Wrong user name. Only letters, digits, '_', '@'' and '.' allowed"
  WRONG_PASSWORD_CONFIRMATION_MASG = 'Password and confirmation must be the same'
  EMPTY_USER_NAME_MSG = 'User name must not be empty'
  SHORT_PASSWORD_MSG = 'Password must have not more or equal 4 characters'


  attr_reader :message

  def self.call(env)
    new(env).process.finish
  end

  def initialize env
    @request = Rack::Request.new(env)
  end

  def process
    @session = @request.cookies['codebreaker_session']
    get_current_user
    responce = if ROUTES.include?(@request.path)
      send( ROUTES[@request.path] )
    else
      page_not_found
    end
    @session ? responce.set_cookie('codebreaker_session', @session) : responce.delete_cookie('codebreaker_session')
    responce
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

  def get_current_user
    @current_user = @request.cookies['current_user']
  end


###############################################################################
  def index
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

  def login
    if @request.get?
      render('login')
    elsif @request.post?
      responce = redirect_to(:index)

      @register_msgs = []

      user = User.find_by(name: @request.params["user_name"])
      if user
        if user.password == @request.params["password"]
          responce.set_cookie('current_user', @request.params["user_name"])
        else
          @register_msgs << "Wrong password"
        end
      else
        @register_msgs << "User '#{@request.params["user_name"]}' does not exist"
      end

      if @register_msgs.empty?
        responce
      else
        render(:login)
      end
    end
  end

  def logout
    responce = redirect_to(:index)
    responce.delete_cookie('current_user')
    responce
  end

  def register

    if @request.get?
      render('register')
    elsif @request.post?

      @register_msgs = []
      name = @request.params["user_name"]
      
      if @request.params["user_name"].length == 0
        @register_msgs << EMPTY_USER_NAME_MSG
      elsif (@request.params["user_name"] =~ USER_NAME_REGEX).nil?
        @register_msgs << WRONG_USER_NAME_MSG
      end

      if User.find_by(name: @request.params["user_name"])
        @register_msgs << "Username '#{@request.params["user_name"]}'' already exists"
      end

      @register_msgs << SHORT_PASSWORD_MSG if @request.params["password"].length < PWD_MIN_LENGHT
      @register_msgs << WRONG_PASSWORD_CONFIRMATION_MASG if @request.params["password"] != @request.params["password_confirm"]

      if @register_msgs.empty?
        User.new(name: @request.params["user_name"], password: @request.params["password"]).save
        responce = redirect_to(:index)
        responce.set_cookie('current_user', @request.params["user_name"])
        responce
      else
        render('register')
      end
    end
  end

  def page_not_found
    render(NOT_FOUND_PAGE, STATUS_NOT_FOUND)
  end
end

