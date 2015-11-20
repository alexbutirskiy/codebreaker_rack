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
    context "when '/' path provided" do
      it "returns 'Rack::Response' object" do
        request = double('request', path: '/')
        allow(Rack::Request).to receive(:new).and_return(request)
        test_obj = Racker.new(TEST_ENV)
        expect(test_obj.process).to be_a Rack::Response
      end
    end
  end
end