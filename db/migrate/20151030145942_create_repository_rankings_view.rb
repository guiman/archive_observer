class CreateRepositoryRankingsView < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE MATERIALIZED VIEW repository_rankings AS
        SELECT github_repositories.id as github_repository_id, count(github_pull_requests.id) as pull_request_count
        FROM github_repositories
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.action = 'opened'
        GROUP BY github_repositories.id
        ORDER BY pull_request_count desc
    SQL
  end

  def self.down

    execute <<-SQL
      DROP MATERIALIZED VIEW repository_rankings
    SQL
  end
end
