class CreateGithubPullRequests < ActiveRecord::Migration
  def change
    create_table :github_pull_requests do |t|
      t.time :event_timestamp
      t.references :github_user, index: true, foreign_key: true
      t.string :action
      t.boolean :merged
      t.references :github_repository, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
