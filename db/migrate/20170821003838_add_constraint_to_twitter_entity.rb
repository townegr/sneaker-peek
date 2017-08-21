class AddConstraintToTwitterEntity < ActiveRecord::Migration[5.0]
  def change
    add_index :twitter_entities, [:name, :uid], unique: true
  end
end
