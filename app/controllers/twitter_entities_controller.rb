class TwitterEntitiesController < ApplicationController
  def index
    @twitter_entities = current_user.twitter_entities.order(:name)
  end

  def new
    @twitter_entity = TwitterEntity.new
  end

  def create
    service = TwitterService.(current_user)
    twitter_user = service.fetch twitter_entity_params[:name]

    if create_twitter_entity twitter_user
      redirect_to twitter_entities_path
    else
      redirect_to new_twitter_entity_path
    end
  end

  def update
  end

  def destroy
  end

  private

  def twitter_entity_params
    params.require(:twitter_entity).permit(:name)
  end

  def create_twitter_entity(user)
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
end
