require 'rack'
require 'erb'
require 'bundler/setup'
require 'rg_codebreaker'
require_relative './user'
require_relative './codebreaker_helper'

class Racker
  OK_STATUS = 200
  NOT_FOUND_STATUS = 404
  NOT_FOUND_PAGE = '404'
  UNEXPECTED_BEHAVIOR_TEXT = 'Unexpected request received. ' \
                                'Please send report to admin@codebreaker.com'
  DIGITS = Codebreaker::Settings::DIGITS_TOTAL

  ROOT_PAGE = :index
  ROUTES = { '/' => ROOT_PAGE, '/index' => :index, '/game' => :game,
             '/start' => :start, '/load' => :load, '/register' => :register,
             '/login' => :login, '/logout' => :logout }

  attr_reader :message

  def self.call(env)
    new(env).process.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @session = JSON.load(@request.cookies['codebreaker_session']) || {}
  end

  def process
    response = if ROUTES.include?(@request.path)
                 send(ROUTES[@request.path])
               else
                 page_not_found
               end

    response.set_cookie('codebreaker_session', @session.to_json)

    response
  end

  private

  def render(page, status = OK_STATUS)
    file = File.read("lib/views/#{page}.html.erb")
    layouts = File.read('lib/views/layouts.html.erb')

    content = ERB.new(file).result(binding)
    final = ERB.new(layouts).result(binding)

    @session.delete('flash')

    Rack::Response.new(final, status)
  end

  def redirect_to(page)
    response = Rack::Response.new
    response.redirect("/#{page}")
    response
  end

  include CodebreakerHelper
end
