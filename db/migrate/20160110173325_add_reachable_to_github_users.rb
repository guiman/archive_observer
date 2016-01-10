class AddReachableToGithubUsers < ActiveRecord::Migration
  def change
    add_column :github_users, :reachable, :boolean, default: true
  end
end
