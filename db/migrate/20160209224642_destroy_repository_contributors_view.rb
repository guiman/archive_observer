class DestroyRepositoryContributorsView < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      DROP MATERIALIZED VIEW repository_contributors
    SQL
  end

  def self.down
    execute <<-SQL
      CREATE MATERIALIZED VIEW repository_contributors AS
        SELECT DISTINCT github_users.login, count(github_pull_requests.id) as prs, github_repositories.full_name
        FROM github_users
        INNER JOIN github_pull_requests ON github_pull_requests.github_user_id = github_users.id
        INNER JOIN github_repositories ON github_repositories.id = github_pull_requests.github_repository_id
        GROUP BY github_users.login, github_repositories.full_name
        ORDER BY prs desc
    SQL
  end
end
