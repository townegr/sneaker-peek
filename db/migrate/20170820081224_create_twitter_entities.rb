class CreateTwitterEntities < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_entities do |t|
      t.string :name
      t.string :uid
      t.string :profile_image
      t.integer :tweet_count, null: false, default: 0
      t.integer :follower_count, null: false, default: 0

      t.timestamps
    end
  end
end
