class CreateGithubPushes < ActiveRecord::Migration
  def change
    create_table :github_pushes do |t|
      t.string :event_timestamp
      t.string :commit_count
      t.integer :original_id
      t.references :github_repository, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
