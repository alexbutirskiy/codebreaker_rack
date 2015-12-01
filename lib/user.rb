require 'rg_codebreaker'
require 'yaml'

class User
  attr_accessor :name, :password
  @@users = []

  def self.find_by(fields = {})
    raise ArgumentError, 'wrong number of arguments (0 for 1+)' if fields.empty?
  end

  def self.save(users)
    raise ArgumentError, 'argument must be an Array' unless users.kind_of? Array
    f = File.open('users.yaml', 'w')
    f.write users.to_yaml
    f.close
  end

  def self.restore
    begin
      f = File.open('users.yaml', 'r')
      @@users = YAML.load(f.read)
    rescue
      @@users = []
    ensure
      f.close unless f.nil?
    end
  end

  private_class_method :save

  def initialize(attributes = {})
    self.name = attributes[:name]
    self.password = attributes[:password]
  end

  def save
    if name.is_a?(String) and password.is_a?(String)
      self.class.send :restore
      @@users << self
      self.class.send :save
      true
    else
      false
    end
  end

  def destroy
    self.class.send :restore
    @@users << self
    self.class.send :save
  end

end
