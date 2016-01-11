class AddLinkedinLinkToGithubUsers < ActiveRecord::Migration
  def change
    add_column :github_users, :linkedin_link, :string
  end
end
