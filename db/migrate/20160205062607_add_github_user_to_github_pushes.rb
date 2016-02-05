class AddGithubUserToGithubPushes < ActiveRecord::Migration
  def change
    add_reference :github_pushes, :github_user, index: true, foreign_key: true
  end
end
