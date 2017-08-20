class Following < ApplicationRecord
  belongs_to :user
  belongs_to :twitter_entity
end
