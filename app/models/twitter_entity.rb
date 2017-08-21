class TwitterEntity < ApplicationRecord
  has_many :followings
  has_many :users, through: :followings

  validates_uniqueness_of :name
  validates_uniqueness_of :uid

  def get_tweets_with_likes(client)
    tweet_objects = client.user_timeline(name).select{ |t| !t.retweet? }
    tweet_objects.each_with_object({}) do |tweet, hash|
      hash[tweet.favorite_count] = tweet.full_text
    end
  end
end
