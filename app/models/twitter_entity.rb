class TwitterEntity < ApplicationRecord
  has_many :followers
  has_many :users, through: :followers
end
