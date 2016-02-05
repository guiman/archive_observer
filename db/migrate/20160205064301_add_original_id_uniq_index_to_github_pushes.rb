class AddOriginalIdUniqIndexToGithubPushes < ActiveRecord::Migration
  def change
    add_index :github_pushes, :original_id, unique: true
  end
end
