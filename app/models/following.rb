class Following < ApplicationRecord
  belongs_to :user
  belongs_to :twitter_entity

  validates_presence_of :user_id
  validates_presence_of :twitter_entity_id
end
