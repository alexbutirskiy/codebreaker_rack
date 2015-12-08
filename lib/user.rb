require 'rg_codebreaker'
require 'yaml'

class Racker
  class User
    attr_accessor :name, :password, :created_at

    def self.find_by(fields = {})
      raise ArgumentError, 'wrong number of arguments (0 for 1+)' if fields.empty?

      users = restore.select do |u|
        fields.each do |k, v|
          begin
            break false unless u.public_send(k) == v
          rescue NoMethodError
            raise ArgumentError, "Attribute user.#{k} does not exist"
          end
        end
      end

      users.empty? ? nil : users.first
    end

    def self.save(users)
      raise ArgumentError, 'argument must be an Array' unless users.is_a? Array
      f = File.open('users.yaml', 'w')
      f.write users.to_yaml
      f.close
    end

    def self.restore
      f = File.open('users.yaml', 'r')
      YAML.load(f.read)
    rescue
      []
    ensure
      f.close unless f.nil?
    end

    private_class_method :save, :restore

    def initialize(attributes = {})
      self.name = attributes[:name]
      self.password = attributes[:password]
      self.created_at = Time.now
    end

    def save
      return false if !name.is_a?(String) || name.empty?
      return false if !password.is_a?(String) || password.empty?

      users = self.class.send(:restore)

      index = users.index { |a| a.name == name }

      if index
        if users[index].created_at == created_at
          users.delete_at(index)
        else
          return false
        end
      end

      users << self
      self.class.send(:save, users)
      true
    end

    def destroy
      users = self.class.send :restore
      users -= Array(self)
      self.class.send(:save, users)
    end

    def ==(other)
      name == other.name &&
        password == other.password &&
        created_at == other.created_at
    end
  end
end
