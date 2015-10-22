class CreateGithubUsers < ActiveRecord::Migration
  def change
    create_table :github_users do |t|
      t.string :login
      t.string :avatar_url

      t.timestamps null: false
    end
  end
end
