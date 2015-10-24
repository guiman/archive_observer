class ChangeTimeFormatInPullRequests < ActiveRecord::Migration
  def change
    remove_column :github_pull_requests, :event_timestamp, :time
    add_column :github_pull_requests, :event_timestamp, :timestamptz
  end
end
