class TwitterEntitiesController < ApplicationController
  def index
    @entities = current_user.twitter_entities
  end

  def new
  end

  def create
  end

  def update
  end

  def destroy
  end
end
