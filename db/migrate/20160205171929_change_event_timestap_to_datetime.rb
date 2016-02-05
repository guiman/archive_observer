class ChangeEventTimestapToDatetime < ActiveRecord::Migration
  def change
    change_column :github_pushes, :event_timestamp, 'timestamptz USING CAST(event_timestamp AS timestamptz)'
  end
end
