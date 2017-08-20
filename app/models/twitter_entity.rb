class TwitterEntity < ApplicationRecord
  has_many :followings
  has_many :users, through: :followings
end
