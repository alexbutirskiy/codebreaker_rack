require 'spec_helper'
describe User do
  after(:each) { User.class_variable_set(:@@users, []) }

  USER_NAME = 'User name'
  USER_PASSWORD = 'password'
  USERS_TEST_ARR = [
    { :name=>"P.McCartney", :password=>"BandOnTheRun" },
    { :name=>"J.Lennon", :password=>"Imagine" }
  ]


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

  describe '.find_by' do
    it 'raise an ArgumentError if no argument provided' do
      expect{ User.find_by }.to raise_exception ArgumentError
    end 

    xit 'raise an ArgumentError if wrong argument provided' do
      expect{ User.find_by(missing: 'text') }.to raise_exception ArgumentError

    end 
  end

  describe '.save private class method' do
    before(:each) do
      @file_handle = double('File handle')
      allow(File).to receive(:open).and_return(@file_handle)
    end

    context 'when argument is not given' do
      it 'raises ArgumentError' do
        expect{ User.send(:save) }.to raise_exception ArgumentError
      end
    end

    context 'when argument is not an Array' do
      it 'raises ArgumentError' do
        expect{ User.send(:save, {}) }.to raise_exception ArgumentError
      end
    end

    context 'when argument is an Array' do
      it 'saves given array to file "users.yaml" in yaml format' do
        expect(File).to receive(:open).with('users.yaml', 'w')
        expect(@file_handle).to receive(:write).with(USERS_TEST_ARR.to_yaml)
        expect(@file_handle).to receive(:close)
        User.send(:save, USERS_TEST_ARR)
      end
    end
  end

  # describe '.restore private class method' do
  #   it 'restores @@users variable from file "users.yaml"' do
  #     file_handle = double('File handle')
  #     expect(File).to receive(:open).with('users.yaml', 'r').and_return(file_handle)
  #     expect(file_handle).to receive(:read).and_return(USERS_TEST_ARR.to_yaml)
  #     expect(file_handle).to receive(:close)
  #     User.send :restore
  #     expect(User.class_variable_get(:@@users)).to eq(USERS_TEST_ARR)
  #   end
  # end

  let(:user) { User.new }

  it 'has a "name" attribute with full access' do
    user.name = USER_NAME  
    expect(user.name).to eq USER_NAME 
  end

  it 'has a "password" attribute with full access' do
    user.password = USER_PASSWORD
    expect(user.password).to eq USER_PASSWORD
  end

  # describe '#save' do

  #   context 'when both "name" and "password" are defined' do
  #     let(:user) { User.new(name: USER_NAME, password: USER_PASSWORD) }

  #     it 'calls User.restore' do
  #       expect(User).to receive(:restore)
  #       user.save
  #     end

  #     it 'adds self to @@users dimension' do
  #       user.save
  #       expect(User.class_variable_get(:@@users).last).to eq user
  #     end

  #     it 'calls User.save' do
  #       expect(User).to receive(:save)
  #       user.save
  #     end

  #     it 'returns "true"' do
  #       expect(user.save).to eq true
  #     end
  #   end

  #   context 'when "name" is not defined' do
  #     let(:user) { User.new(password: USER_PASSWORD) }

  #     it 'doesn\'t call User.save' do
  #       user = User.new(password: USER_NAME)
  #       expect(User).to_not receive(:save)
  #       expect(user.save).to eq false
  #     end

  #     it 'returns "false"' do
  #       expect(user.save).to eq false
  #     end
  #   end
  # end

  # describe '.destroy' do
  #   context 'when name is not defined' do
  #     xit 'returns "false"' do

  #     end
  #   end
  # end
end
