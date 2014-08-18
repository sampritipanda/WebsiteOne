class AuthenticationProvider < ActiveRecord::Base
  has_many :users
  has_many :authentications

  validates :name, uniqueness: true
end
