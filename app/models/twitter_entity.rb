class TwitterEntity < ApplicationRecord
  has_many :followings
  has_many :users, through: :followings

  validates_uniqueness_of :name
  validates_uniqueness_of :uid

  def self.for_user(auth_user)
    auth_user.twitter_entities.order(:name)
  end

  def self.create_hierarchy_for_json(auth_user, service)
    { auth_user.uid => [
        self.for_user(auth_user).map do |entity|
          target = service.fetch(target_name = entity.name)
          {
            target: target.id,
            name: target_name,
            tweet_count: target.tweets_count,
            follower_count: target.followers_count,
            recent_tweets: [entity.get_tweets_with_likes(service)]
          }
        end
      ]
    }
  end

  def self.find_or_update_twitter_entities(auth_user, service)
    self.for_user(auth_user).tap { |entities|
      entities.each do |entity|
        target = service.fetch entity.name
        new_params = {
          tweet_count: target.tweets_count,
          follower_count: target.followers_count
        }
        entity.assign_attributes new_params
        entity.save! if entity.changed?
      end
    }
  end

  def get_tweets_with_likes(service)
    tweet_objects = service.client.user_timeline(name).select{ |t| !t.retweet? }
    tweet_objects.each_with_object({}) do |tweet, hash|
      hash[tweet.favorite_count] = tweet.full_text
    end
  end
end
