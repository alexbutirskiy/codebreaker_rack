require 'spec_helper'

describe CodebreakerHelper do
  include CodebreakerHelper
  RENDERED_PAGE = 'Rendered page'
  REDIRECTED = 'Responce with rediraction'
  USER = 'CurrentUser'
  USER_PSWD = 'valid_password'
  WRONG_PSWD = 'invalid_password'

  describe '#login' do
    context 'in case of \'GET\' HTTP method request' do
      before(:each) { @request = double('request', get?: true, post?: false) }

      it 'calls \'render\' method' do
        expect(self).to receive(:render).with('login').and_return(RENDERED_PAGE)
        login
      end

      it 'returns \'render\' output' do
        allow(self).to receive(:render).with('login').and_return(RENDERED_PAGE)
        expect(login).to eq RENDERED_PAGE
      end
    end

    context 'in case of \'POST\' HTTP method request' do
      before(:each) do
        @request = double('request', get?: false, post?: true)
        @session = {}
        user = double('user', password: USER_PSWD)
        allow(@request).to receive(:params)
          .and_return({ 'password' => USER_PSWD, 'user_name' => USER })
        allow(Racker::User).to receive(:find_by).with(name: USER)
          .and_return(user)
        allow(self).to receive(:render).and_return(RENDERED_PAGE)
        allow(self).to receive(:redirect_to).and_return(REDIRECTED)
        login
      end

      context "when user #{USER} exists and password is valid" do
        it "sets '@sission['user_name']' to  #{USER}" do
          expect(@session['user_name']).to eq USER
        end

        it "sets '@session['flash']' with 'msg' and 'style' keys" do
          expect(@session['flash'][:msg]).to_not be_nil
          expect(@session['flash'][:style]).to eq 'flash_green'
        end

        it 'redirects to \'index\' page' do
          expect(self).to receive(:redirect_to).with(:index)
          expect(login).to eq REDIRECTED
        end
      end

      context "when user #{USER} exists but password is invalid" do
        before(:each) do
          allow(@request).to receive(:params)
            .and_return({ 'password' => WRONG_PSWD, 'user_name' => USER })
          login
        end

        it 'adds \'Wrong password\' to \'@register_msgs\'' do
          expect(@register_msgs).to include('Wrong password')
        end

        it 'renders \'login\' page' do
          expect(self).to receive(:render).with(:login)
          expect(login).to eq RENDERED_PAGE
        end
      end

      context "when user #{USER} does not exist" do
        before(:each) do
          allow(Racker::User).to receive(:find_by).and_return(nil)
          login
        end
        it 'adds \'User doesn\'t exist\' to \'@register_msgs\'' do
          expect(@register_msgs).to include("User '#{USER}' does not exist")
        end

        it 'renders \'login\' page' do
          expect(self).to receive(:render).with(:login)
          expect(login).to eq RENDERED_PAGE
        end
      end
    end
  end

  describe '#logout' do
    before(:each) do
      @session = {}
      allow(self).to receive(:redirect_to).and_return(REDIRECTED)
      logout
    end

    it "sets '@sission['user_name']' to  #{USER}" do
      expect(@session['user_name']).to eq nil
    end

    it "sets '@session['flash']' with 'msg' and 'style' keys" do
      expect(@session['flash'][:msg]).to_not be_nil
      expect(@session['flash'][:style]).to eq 'flash_green'
    end

    it 'redirects to \'index\' page' do
      expect(self).to receive(:redirect_to).with(:index)
      expect(logout).to eq REDIRECTED
    end
  end

  describe '#register' do
    context 'in case of \'GET\' HTTP method request' do
      before(:each) { @request = double('request', get?: true, post?: false) }

      it 'renders \'register\' page' do
          expect(self).to receive(:render).with('register').and_return(RENDERED_PAGE)
          expect(register).to eq RENDERED_PAGE
      end 
    end
  end
end
