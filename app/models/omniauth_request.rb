class OmniauthRequest
  include ActiveModel::Model

  attr_accessor :auth_params

  def is_youtube?
    auth_params['youtube'].present?
  end

  def token
    auth_params['credentials']['token']
  end

  def provider
    AuthenticationProvider.where(name: auth_params['provider']).first!
  end

  def existing_authentication
    provider.authentications.where(uid: auth_params['uid']).first
  end

  def token_expires_at
    expiration = auth_params['credentials']['expires_at']
    Time.at(expiration) if expiration
  end

  def create_authentication(user)
    Authentication.create(
      user: user,
      authentication_provider: provider,
      uid: auth_params['uid'],
      token: token,
      token_expires_at: token_expires_at,
      params: auth_params,
    )
  end

  def existing_user
    User.where('email = ?', auth_params['info']['email']).first
  end

  def create_user
    User.create({
      email: auth_params['info']['email'],
      password: Devise.friendly_token
    })
  end
end
