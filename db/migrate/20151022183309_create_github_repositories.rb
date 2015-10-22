class CreateGithubRepositories < ActiveRecord::Migration
  def change
    create_table :github_repositories do |t|
      t.string :full_name
      t.references :language, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
