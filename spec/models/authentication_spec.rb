require 'spec_helper'

describe Authentication, :type => :model do
  before do
    @user = FactoryGirl.create(:user)
    @auth = @user.authentications.create!(provider: 'github', uid: '12345')
  end

  it 'must have an associated user' do
    # Bryan: validations done at database level to avoid complications, but will raise exceptions
    @auth.user_id = nil
    expect{ @auth.save }.to raise_error
  end

  it 'must have an associated provider' do
    @auth.provider = nil
    expect(@auth.save).to be_falsey
  end

  it 'must have an associated UID' do
    @auth.uid = nil
    expect(@auth.save).to be_falsey
  end

  it 'must have a unique user-provider combination' do
    auth = @user.authentications.build(provider: 'github', uid: '098766')
    expect(auth.save).to be_falsey
  end
end
