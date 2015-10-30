class AddNewUniqueIndexes < ActiveRecord::Migration
  def self.up
    add_index :github_users, :login, unique: true, name: "index_github_users_login"
    add_index :github_repositories, :full_name, unique: true
    add_index :languages, :name, unique: true
  end

  def self.down
    remove_index :github_users, name: "index_github_users_login"
    remove_index :github_repositories, :full_name
    remove_index :languages, :name
  end
end
