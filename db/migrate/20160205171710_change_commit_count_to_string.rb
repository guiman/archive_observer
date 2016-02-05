class ChangeCommitCountToString < ActiveRecord::Migration
  def change
    change_column :github_pushes, :commit_count, 'integer USING CAST(commit_count AS integer)'
  end
end
