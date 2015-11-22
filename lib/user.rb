require 'rg_codebreaker'

class User
  attr_accessor :name, :password
end

class Users
  include Codebreaker::Saver

  def initialize
    @users = []
    restore
  end

  def add(user)
    raise ArgumentError, "#{user} is not User class" unless user.is_a? User
    @users += user
    save
  end

end