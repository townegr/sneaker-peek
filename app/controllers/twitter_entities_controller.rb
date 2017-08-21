class TwitterEntitiesController < ApplicationController
  before_action :set_twitter_entity, only: [:edit, :show, :update, :destroy]
  before_action :twitter_service, only: [:index, :create, :show]

  def index
    @twitter_entities = find_or_update_twitter_entities @twitter_service
  end

  def new
    @twitter_entity = TwitterEntity.new
  end

  def create
    twitter_user = @twitter_service.fetch twitter_entity_params[:name]

    respond_to do |format|
      if create_twitter_entity twitter_user
        format.html { redirect_to twitter_entities_path, notice: 'Successfully created!' }
      else
        format.html { redirect_to new_twitter_entity_path }
      end
    end
  end

  def show
    client = @twitter_service.client
    @tweets = @twitter_entity.get_tweets_with_likes client
  end

  def update
  end

  def destroy
  end

  private

  def set_twitter_entity
    @twitter_entity = TwitterEntity.find_by_id params[:id]
  end

  def twitter_service
    @twitter_service = TwitterService.(current_user)
  end

  def twitter_entity_params
    params.require(:twitter_entity).permit(:name)
  end

  def create_twitter_entity(twitter_user)
    TwitterEntity.transaction do
      twitter_entity = TwitterEntity.find_or_create_by!(
        name: user.screen_name,
        uid: user.id,
        profile_image: user.profile_image_uri.to_str
      )
      current_user.followings.find_or_create_by! twitter_entity: twitter_entity
    end
  rescue ActiveRecord::RecordInvalid => exception
    raise exception, (_("Unable to create Twitter Entity: %s") % exception.message), exception.backtrace
  end

  def find_or_update_twitter_entities(service)
    twitter_entities = current_user.twitter_entities.order(:name)
    twitter_entities.tap { |entities|
      entities.each do |entity|
        user = service.fetch entity.name
        new_params = {
          tweet_count: user.tweets_count,
          follower_count: user.followers_count
        }
        entity.assign_attributes new_params
        entity.save! if entity.changed?
      end
    }
  end
end
