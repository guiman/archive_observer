class CreateUserRankingsView < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE MATERIALIZED VIEW user_rankings AS
        SELECT github_users.id as github_user_id, count(github_pull_requests.id) as pull_request_count
        FROM github_users
        INNER JOIN github_pull_requests on github_pull_requests.github_user_id = github_users.id
        WHERE github_pull_requests.action = 'opened'
        GROUP BY github_users.id
        ORDER BY pull_request_count desc
    SQL
  end

  def self.down
    execute <<-SQL
      DROP MATERIALIZED VIEW user_rankings
    SQL
  end
end
