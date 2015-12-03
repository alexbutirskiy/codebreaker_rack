require 'spec_helper'
describe User do
  USER_NAME = 'User name'
  USER_PASSWORD = 'password'
  MCCARTNEY = 'P.McCartney'
  LENNON = 'J.Lennon'

  let(:lennon) { User.new(name: LENNON, password: 'Imagine') }
  let(:mccartney) { User.new(name: MCCARTNEY, password: 'BandOnTheRun') }
  let(:users_test_arr) { [] << lennon << mccartney }

  describe '.new class method' do
    it 'sets user name if "name" attribute provided' do
      user = User.new(name: USER_NAME)
      expect(user.name).to eq USER_NAME
    end

    it 'sets user password if "password" attribute provided' do
      user = User.new(password: USER_PASSWORD)
      expect(user.password).to eq USER_PASSWORD
    end
  end

  describe '.save private class method' do
    before(:each) do
      @file_handle = double('File handle')
      allow(File).to receive(:open).and_return(@file_handle)
    end

    context 'when argument is not given' do
      it 'raises ArgumentError' do
        expect { User.send(:save) }.to raise_exception ArgumentError
      end
    end

    context 'when argument is not an Array' do
      it 'raises ArgumentError' do
        expect { User.send(:save, {}) }.to raise_exception ArgumentError
      end
    end

    context 'when argument is an Array' do
      it 'saves given array to file "users.yaml" in yaml format' do
        expect(File).to receive(:open).with('users.yaml', 'w')
        expect(@file_handle).to receive(:write).with(users_test_arr.to_yaml)
        expect(@file_handle).to receive(:close)
        User.send(:save, users_test_arr)
      end
    end
  end

  describe '.restore private class method' do
    it 'returns array of users loaded from file "users.yaml"' do
      file_handle = double('File handle')
      expect(File).to receive(:open).with('users.yaml', 'r').and_return(file_handle)
      expect(file_handle).to receive(:read).and_return(users_test_arr.to_yaml)
      expect(file_handle).to receive(:close)
      expect(User.send(:restore)).to eq(users_test_arr)
    end

    it 'returns an empty array if "users.yaml" file abscent or broken' do
      file_handle = double('File handle')
      expect(File).to receive(:open).and_return(file_handle)
      expect(file_handle).to receive(:read).and_raise(Errno::ENOENT)
      expect(file_handle).to receive(:close)
      expect(User.send(:restore)).to eq([])
    end
  end

  describe '.find_by' do
    before(:each) do
      allow(User).to receive(:restore).and_return(users_test_arr)
    end

    context 'when "name" field provided and user exists' do
      it 'returns object of the User class' do
        expect(User.find_by(name: LENNON)).to be_a User
      end

      it 'returns requested object' do
        user = User.find_by(name: LENNON)
        expect(user.name).to eq LENNON
      end
    end

    context 'when "name" field provided and user does not exist' do
      it 'returns "nil"' do
        user = User.find_by(name: 'Wrong name')
        expect(user).to be_a_nil
      end
    end

    it 'raises an ArgumentError if no argument provided' do
      expect { User.find_by }.to raise_exception ArgumentError
    end

    it 'raises an ArgumentError if wrong field provided' do
      expect { User.find_by(missing: 'text') }.to raise_exception ArgumentError
    end
  end

  let(:user) { User.new }

  it 'has a "name" attribute with full access' do
    user.name = USER_NAME
    expect(user.name).to eq USER_NAME
  end

  it 'has a "password" attribute with full access' do
    user.password = USER_PASSWORD
    expect(user.password).to eq USER_PASSWORD
  end

  describe '#save' do
    before(:each) do
      allow(User).to receive(:save)
      allow(User).to receive(:restore).and_return(users_test_arr)
    end

    context 'when both "name" and "password" are defined' do
      let(:user) { User.new(name: USER_NAME, password: USER_PASSWORD) }

      it 'calls User.restore' do
        expect(User).to receive(:restore).and_return([])
        user.save
      end

      it 'calls ".save" class method with array included "user"' do
        expect(User).to receive(:save).with(array_including(user))
        user.save
      end

      it 'returns "true"' do
        allow(User).to receive(:save)
        expect(user.save).to eq true
      end
    end

    context 'when "name" is not defined' do
      let(:user) { User.new(password: USER_PASSWORD) }

      it 'doesn\'t call User.save' do
        expect(User).to_not receive(:save)
        expect(user.save).to eq false
      end

      it 'returns "false"' do
        expect(user.save).to eq false
      end
    end

    context 'when "password" is not defined' do
      let(:user) { User.new(name: USER_NAME) }

      it 'doesn\'t call User.save' do
        expect(User).to_not receive(:save)
        expect(user.save).to eq false
      end

      it 'returns "false"' do
        expect(user.save).to eq false
      end
    end

    context 'when user with the same name is already exist' do
      it 'does not call ".save" class method' do
        user = User.new(name: LENNON, password: USER_PASSWORD)
        expect(User).to_not receive(:save)
        user.save
      end

      it 'returns false' do
        user = User.new(name: LENNON, password: USER_PASSWORD)
        expect(user.save).to eq false
      end
    end
  end

  describe '.destroy' do
    before(:each) do
      allow(User).to receive(:save)
      allow(User).to receive(:restore).and_return(users_test_arr)
    end

    it 'calls ".restore" class method' do
      expect(User).to receive(:restore).and_return(users_test_arr)
      lennon.destroy
    end

    it 'saves user list without current user' do
      expect(User).to receive(:save).with(users_test_arr - Array(lennon))
      lennon.destroy
    end
  end
end
