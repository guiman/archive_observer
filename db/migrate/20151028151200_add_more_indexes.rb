class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :languages, :id, name: 'lang_id_idx'
    add_index :languages, :name, name: 'lang_name_idx'
    add_index :github_repositories, :id, name: 'repo_id_idx'
    add_index :github_users, :login, name: 'user_login_idx'
    add_index :github_pull_requests, :action, name: 'pull_request_action_idx'
  end
end
