class TwitterEntitiesController < ApplicationController
  before_action :reset_session, unless: :signed_in?
  before_action :set_twitter_entity, only: [:edit, :show, :update, :destroy]
  before_action :twitter_service, only: [:index, :create, :show]

  def index
    respond_to do |format|
      if @twitter_entities = TwitterEntity.find_or_update_twitter_entities(current_user, @twitter_service)
        SneakerPeekService.new(@entities = TwitterEntity.fetch_data_for_followings(current_user, @twitter_service)).publish!
        format.html
        format.json { render :index, status: :ok, entities: @entities }
      else
        format.html { render :index }
        format.json { render json: @twitter_entities.errors, status: :unprocessable_entity }
      end
    end
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
    respond_to do |format|
      if @tweets = @twitter_entity.get_tweets_with_likes(@twitter_service)
        SneakerPeekService.new(@entity = @twitter_entity.fetch_data_for_entity(current_user, @twitter_service)).publish!
        format.html
        format.json { render :show, status: :ok, entity: @entity }
      else
        format.html { render :index }
        format.json { render json: @tweets.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
    if @twitter_entity.destroy
      respond_to do |format|
        format.html { redirect_to twitter_entities_path, notice: 'Deleted account' }
      end
    end
  end

  private

  def set_twitter_entity
    query = params[:service] == 'frontend' ? { uid: params[:id] } : { id: params[:id] }
    @twitter_entity = TwitterEntity.find_by query
  end

  def twitter_service
    @twitter_service ||= TwitterService.(current_user)
  end

  def twitter_entity_params
    params.require(:twitter_entity).permit(:name)
  end

  def create_twitter_entity(twitter_user)
    TwitterEntity.transaction do
      twitter_entity = TwitterEntity.find_or_create_by!(
        name: twitter_user.screen_name,
        uid: twitter_user.id,
        profile_image: twitter_user.profile_image_uri.to_str
      )
      current_user.followings.find_or_create_by! twitter_entity: twitter_entity
    end
  rescue ActiveRecord::RecordInvalid => exception
    raise exception, ("Unable to create Twitter Entity: %s" % exception.message), exception.backtrace
  end
end
