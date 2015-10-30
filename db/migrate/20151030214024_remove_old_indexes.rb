class RemoveOldIndexes < ActiveRecord::Migration
  def self.up
    remove_index :github_users, name: "user_login_idx"
    remove_index :languages, name: 'lang_name_idx'
  end

  def self.down
    add_index :languages, :name, name: 'lang_name_idx'
    add_index :github_users, :login, name: 'user_login_idx'
  end
end
