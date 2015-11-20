require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rspec'
require 'bundler/setup'
require './lib/codebreaker_game'

describe Racker do
  TEST_ENV = 'Envirenment'
  TEST_OUT = [200, {}, ["Test"]]
  describe '.call' do
    it "calls one by one 'new', 'process' and 'finish' methods" do
      expect(Racker).to receive_message_chain(:new, :process, :finish)
      Racker.call(TEST_ENV)
    end

    it "returns 'finish' method output" do
      allow(Racker).to receive_message_chain(:new, :process, finish: TEST_OUT)
      expect(Racker.call(TEST_ENV)).to eq TEST_OUT
    end
  end

  describe '#process' do

    ROUTES = {'/' => 'index', '/game' => 'game'}

    ROUTES.each do |path, page|
      context "when #{path} path provided" do
        before(:each) do
          request = double('request', path: path, post?: false)
          allow(Rack::Request).to receive(:new).and_return(request)
          @test_obj = Racker.new(TEST_ENV)
        end
        it "calls 'render' method with '#{page}' argument" do
          expect(@test_obj).to receive(:render).with("#{page}").and_return(Rack::Response.new)
          @test_obj.process
        end

        it "returns 'Rack::Response' object" do
          expect(@test_obj.process).to be_a Rack::Response
        end
      end
    end
  end
end