class AddOriginalIdColumnToGithubPullRequests < ActiveRecord::Migration
  def change
    add_column :github_pull_requests, :original_id, :integer
    add_index :github_pull_requests, :original_id, unique: true
  end
end
