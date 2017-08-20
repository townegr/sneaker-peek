class TwitterService
  attr_reader :user, :client

  def self.call(user)
    new(user: user).tap(&:configure_client)
  end

  def initialize(user:, client: Twitter::REST::Client.new)
    @user = user
    @client = client
  end

  def configure_client
    client.consumer_key        = Rails.application.secrets.twitter_api_key
    client.consumer_secret     = Rails.application.secrets.twitter_api_secret
    client.access_token        = user.token
    client.access_token_secret = user.secret
  end

  def fetch(name)
    client.user name
  end
end
