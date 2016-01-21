class AddForkToGithubRepositories < ActiveRecord::Migration
  def change
    add_column :github_repositories, :fork, :boolean
  end
end
