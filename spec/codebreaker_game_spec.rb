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

  describe '#render' do
    PAGE_NAME = 'index'
    PAGE_PATH = "lib/views/#{PAGE_NAME}.html.erb"
    FILE_CONTENT = 'Some text'
    STATUS_OK = 200
    before(:each) do
      allow(File).to receive(:read).and_return(FILE_CONTENT)
      allow(ERB).to receive_message_chain(:new, result: FILE_CONTENT)
      allow(Rack::Responce).to receive(:new)  #.with(FILE_CONTENT, STATUS_OK)
    end
    context "when takes a '#{PAGE_NAME}' string as a page name"
    it "calls 'File.read' with #{PAGE_PATH}" do
      expect(File).to receive(:read).and_return(FILE_CONTENT)
      
    end
  end

  describe '#process' do
    context "when '/' path provided" do
      before(:each) do
        request = double('request', path: '/')
        allow(Rack::Request).to receive(:new).and_return(request)
        @test_obj = Racker.new(TEST_ENV)
      end
      it "calls 'render' method with 'index' argument" do
        expect(@test_obj).to receive(:render).with('index').and_return(Rack::Response.new)
        @test_obj.process
      end

      it "returns 'Rack::Response' object" do
        expect(@test_obj.process).to be_a Rack::Response
      end
    end
  end
end