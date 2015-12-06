require 'spec_helper'

describe Racker do
  TEST_ENV = 'Envirenment'
  TEST_OUT = [200, {}, ["Test"]]
  NOT_DEFINED_PATH = '/not_defined'
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
    Racker::ROUTES.each do |path, method|
      context "when @request.path is '#{path}'" do
        before(:each) do
          request = double('request', path: path, cookies: {})
          allow(Rack::Request).to receive(:new).and_return(request)
          @test_obj = Racker.new(TEST_ENV)
        end

        it "calls a '#{method}' method" do
          expect(@test_obj).to receive(method)
          @test_obj.process
        end

        it "returns '#{method}' method output" do
          allow(@test_obj).to receive(method).and_return(TEST_OUT)
          expect(@test_obj.process).to eq TEST_OUT
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
        expect(@test_obj).to receive(:page_not_found)
        @test_obj.process
      end
        it "returns '#page_not_found' method output" do
          allow(@test_obj).to receive(:page_not_found).and_return(TEST_OUT)
          expect(@test_obj.process).to eq TEST_OUT
        end
    end
  end


end
