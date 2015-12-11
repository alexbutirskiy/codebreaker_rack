require 'spec_helper'

describe Racker do
  TEST_ENV = 'Envirenment'
  TEST_OUT = [200, {}, ['Test']]
  NOT_DEFINED_PATH = '/not_defined'
  COOKIE_SESSION = 'codebreaker_session'
  COOKIE_KEY = 'state'
  COOKIE_DATA = 'some'

  before(:each) do
    @serialized = {COOKIE_KEY=>COOKIE_DATA}.to_json
    request = double('request', path: '/', cookies: {COOKIE_SESSION => @serialized})
    allow(Rack::Request).to receive(:new).and_return(request)
    # @racker = Racker.new(TEST_ENV)
  end

  let(:racker) { Racker.new(TEST_ENV) }

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

      it "fills '@session' with data stored in cookie #{COOKIE_SESSION}" do
        racker.process
        expect(racker.instance_variable_get(:@session)[COOKIE_KEY]).to eq COOKIE_DATA
      end

      it "stores data from '@session' in cookie #{COOKIE_SESSION}" do
        response = double('response')
        allow(Rack::Response).to receive(:new).and_return(response)
        expect(response).to receive(:set_cookie).with(COOKIE_SESSION, @serialized)
        racker.process
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

  describe '#render' do
    SOME_PAGE = 'some_page'
    TEST_STATUS = 402
    OK_STATUS = 200
    VIEWS_LOCATION = 'lib/views/'
    SOME_CONTENT = 'Some content'

    let(:layouts) { 'Layouts file' }
    let(:page) { 'Page file' }

    before(:each) do
     allow(File).to receive(:read).and_return(SOME_CONTENT) 
    end

    context "wnen '#{SOME_PAGE}' given" do
      it "reads 'layouts.html.erb'" do
        expect(File).to receive(:read).with(VIEWS_LOCATION + "layouts.html.erb")
        racker.send(:render, SOME_PAGE)
      end

      it "reads '#{VIEWS_LOCATION +  SOME_PAGE}.html.erb'" do
        expect(File).to receive(:read).with(VIEWS_LOCATION + SOME_PAGE + ".html.erb")
        racker.send(:render, SOME_PAGE)
      end

      it "calls Rack::Response.new with '#{SOME_CONTENT}' and #{OK_STATUS}" do
        expect(Rack::Response).to receive(:new).with(SOME_CONTENT, OK_STATUS)
        racker.send(:render, SOME_PAGE)
      end
    end

    context "when '#{SOME_PAGE}' page and #{TEST_STATUS} status given" do
      it "calls Rack::Response.new with '#{SOME_CONTENT}' and #{TEST_STATUS}" do
        expect(Rack::Response).to receive(:new).with(SOME_CONTENT, TEST_STATUS)
        racker.send(:render, SOME_PAGE, TEST_STATUS)
      end
    end

    it 'deletes "flash" from @session' do
      session = double('session')
      expect(session).to receive(:delete).with('flash')
      racker.instance_variable_set(:@session, session)
      racker.send(:render, SOME_PAGE)
    end 
  end

  describe '#redirect_to' do

  end
end
