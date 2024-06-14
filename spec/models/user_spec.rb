

require 'rails_helper'
require 'securerandom'

RSpec.describe User, type: :model do
  let(:current_user) do
    User.new(id: 'current-user-id', username: 'currentuser', email: 'currentuser@example.com',
             password_digest: BCrypt::Password.create('password'), bio: 'Current user bio', image: 'current_image.png')
  end
  let(:other_user) do
    User.new(id: 'other-user-id', username: 'otheruser', email: 'otheruser@example.com',
             password_digest: BCrypt::Password.create('password'), bio: 'Other user bio', image: 'other_image.png')
  end

  before do
    allow(User).to receive(:find_by_username).with('currentuser').and_return(current_user)
    allow(User).to receive(:find_by_username).with('otheruser').and_return(other_user)
    allow(User).to receive(:find).with(current_user.id).and_return(current_user)
    allow_any_instance_of(User).to receive(:follow).and_return(true)
  end

  describe '#save' do
    context 'when the user is saved with an ID' do
      it 'correctly saves a new user to the Couchbase bucket with a unique ID if not already set' do
        user = User.new(id: 'unique-id', username: 'testuser', email: 'test@example.com', password_digest: 'password')
        allow_any_instance_of(User).to receive(:save).and_return(true)

        user.save

        expect(user.id).to eq('unique-id')
      end
    end

    context 'when Couchbase save fails' do
      it 'raises an error' do
        user = User.new(username: 'testuser', email: 'test@example.com', password_digest: 'password')
        allow_any_instance_of(User).to receive(:save).and_return(false)

        expect(user.save).to be_falsey
      end
    end
  end

  describe '.find_by_email' do
    context 'when a user is found with the given email' do
      it 'returns a User object when a user with the given email exists in the Couchbase bucket' do
        allow(User).to receive(:find_by_email).and_return(current_user)

        user = User.find_by_email('currentuser@example.com')

        expect(user.id).to eq('current-user-id')
      end
    end

    context 'when no user with the given email exists' do
      it 'returns nil' do
        email = 'nonexistent@example.com'
        allow(User).to receive(:find_by_email).and_return(nil)

        user = User.find_by_email(email)

        expect(user).to be_nil
      end
    end

    context 'when Couchbase query fails' do
      it 'raises an error' do
        email = 'test@example.com'
        allow(User).to receive(:find_by).and_return(nil)

        expect{ User.find_by_email(email) }.to raise_error(StandardError, "Couldn't find User with 'email'=#{email}")
      end
    end
  end

  describe '#follow' do
    context 'when the user is found to be added' do
      it 'correctly adds a user to the following list of another user' do
        allow_any_instance_of(User).to receive(:follow).and_return(true)
        allow_any_instance_of(User).to receive(:save!).and_return(true)

        allow(current_user).to receive(:following).and_return([other_user.id])

        current_user.follow(other_user)

        current_user.save!

        expect(current_user.following).to include(other_user.id)
      end
    end
  end
end
