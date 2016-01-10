class AddLocationToGithubUsers < ActiveRecord::Migration
  def change
    add_column :github_users, :location, :string
  end
end
