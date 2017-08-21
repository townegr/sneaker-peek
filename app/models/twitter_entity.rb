class TwitterEntity < ApplicationRecord
  has_many :followings
  has_many :users, through: :followings

  validates_uniqueness_of :name
  validates_uniqueness_of :uid
end
