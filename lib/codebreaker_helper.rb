require 'byebug'

module CodebreakerHelper
  DB_PATH = 'db/'
  PWD_MIN_LENGHT = 4
  USER_NAME_REGEX = /^[a-zA-Z0-9_@.]+$/
  WRONG_USER_NAME_MSG = "Wrong user name. " \
    "Only letters, digits, '_', '@'' and '.' allowed"
  WRONG_PASSWORD_CONFIRMATION_MASG = 'Password and confirmation must be the same'
  EMPTY_USER_NAME_MSG = 'User name must not be empty'
  SHORT_PASSWORD_MSG = 'Password must have not more or equal 4 characters'

  def index
    render('index')
  end

  def login
    if @request.get?
      render('login')
    elsif @request.post?
      responce = redirect_to(:index)

      @register_msgs = []

      user = Racker::User.find_by(name: @request.params['user_name'])

      if user
        if user.password == @request.params["password"]
          @session['user_name'] = @request.params['user_name']
        else
          @register_msgs << "Wrong password"
        end
      else
        @register_msgs << "User '#{@request.params["user_name"]}' does not exist"
      end

      if @register_msgs.empty?
        @session['flash'] = { msg: 'You successfully logged in', style: 'flash_green' }
        responce
      else
        render(:login)
      end
    end
  end

  def logout
    responce = redirect_to(:index)
    @session['user_name'] = nil
    @session['flash'] = { msg: 'You successfully logged out', style: 'flash_green' }
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

      if Racker::User.find_by(name: @request.params["user_name"])
        @register_msgs << "Username '#{@request.params["user_name"]}'' already exists"
      end

      @register_msgs << SHORT_PASSWORD_MSG if @request.params["password"].length < PWD_MIN_LENGHT
      @register_msgs << WRONG_PASSWORD_CONFIRMATION_MASG if @request.params["password"] != @request.params["password_confirm"]

      if @register_msgs.empty?
        Racker::User.new(name: @request.params["user_name"], password: @request.params["password"]).save
        responce = redirect_to(:index)
        @session['user_name'] = @request.params['user_name']
        @session['flash'] = { msg: 'You successfully logged in', style: 'flash_green' }
        responce
      else
        render('register')
      end
    end
  end


  def game
    return redirect_to(:login) if current_user.nil?

    @game = Codebreaker::Game.new

    begin
      @game.restore(games_path(current_user))
    rescue
      @session['flash'] = { msg: "It looks like you don't have any saved game", 
                            style: 'flash_red' }
      return redirect_to(:index)
    end

    if @request.post?
      params = @request.params

      if params["hint"]
        @msg = "Hint: #{@game.hint}"
        @game.save(games_path(current_user))
      elsif params["number"]
        if @game.input_valid?(params["number"])
          @answer = @game.guess(params["number"])
          @game.save(games_path(current_user))
          return render('win') if @game.win?
          return render('lose') if @game.lose?
        else
          @game_error_msg = "Invalid input. You should enter #{DIGITS} numbers from 1 to 6"
        end
      else
        @msg = UNEXPECTED_BEHAVIOR_TEXT
      end
    end

    render('game')
  end

  def start
    if current_user.nil?
      @session['flash'] = { msg: 'You have not logged in yet', style: 'flash_red' }
      return redirect_to(:login)
    end

    @game = Codebreaker::Game.new
    @game.save(games_path(current_user))
    redirect_to :game
  end

  def load
    if current_user.nil?
      @session['flash'] = { msg: 'You have not logged in yet', style: 'flash_red' }
      return redirect_to(:login)
    end

    redirect_to :game
  end

  def page_not_found
    render(NOT_FOUND_PAGE, STATUS_NOT_FOUND)
  end

  def current_user
    @session['user_name']
  end

  def games_path(user)
    raise ArgumentError, 'User is not a String' unless user.is_a? String
    DB_PATH + user
  end
end