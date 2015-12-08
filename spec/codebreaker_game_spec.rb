require 'spec_helper'

describe Racker do
  TEST_ENV = 'Envirenment'
  TEST_OUT = [200, {}, ['Test']]
  NOT_DEFINED_PATH = '/not_defined'
  COOKIE_SESSION = 'codebreaker_session'
  COOKIE_KEY = 'state'
  COOKIE_DATA = 'some'

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
    let(:response) {Rack::Response.new}

    describe 'keeps seesion state in cookies' do
      before(:each) do
        @serialized = {COOKIE_KEY=>COOKIE_DATA}.to_json
        request = double('request', path: '/', cookies: {COOKIE_SESSION => @serialized})
        allow(Rack::Request).to receive(:new).and_return(request)
        @racker = Racker.new(TEST_ENV)
      end
      it "fills '@session' with data stored in cookie #{COOKIE_SESSION}" do
        @racker.process
        expect(@racker.instance_variable_get(:@session)[COOKIE_KEY]).to eq COOKIE_DATA
      end

      it "stores data from '@session' in cookie #{COOKIE_SESSION}" do
        response = double('response')
        allow(Rack::Response).to receive(:new).and_return(response)
        expect(response).to receive(:set_cookie).with(COOKIE_SESSION, @serialized)
        @racker.process
      end
    end

    Racker::ROUTES.each do |path, method|
      context "when @request.path is '#{path}'" do
        before(:each) do
          request = double('request', path: path, cookies: {})
          allow(Rack::Request).to receive(:new).and_return(request)
          @test_obj = Racker.new(TEST_ENV)
        end

        it "calls a '#{method}' method" do
          expect(@test_obj).to receive(method).and_return(response)
          @test_obj.process
        end

        it "returns '#{method}' method output" do
          allow(@test_obj).to receive(method).and_return(response)
          expect(@test_obj.process).to eq response
        end
      end
    end

    context "when @request.path is '#{NOT_DEFINED_PATH}'" do
      before(:each) do
        request = double('request', path: NOT_DEFINED_PATH, cookies: {})
        allow(Rack::Request).to receive(:new).and_return(request)
        @test_obj = Racker.new(TEST_ENV)
      end

      it "calls #page_not_found method" do
        expect(@test_obj).to receive(:page_not_found).and_return(response)
        @test_obj.process
      end

      it "returns '#page_not_found' method output" do
        allow(@test_obj).to receive(:page_not_found).and_return(response)
        expect(@test_obj.process).to eq response
      end
    end
  end


end
