class CreateRepositoriesRankingTable < ActiveRecord::Migration
  def change
    create_table(:repository_rankings, as: "
      SELECT github_repositories.id as github_repository_id, count(github_pull_requests.id) as pull_request_count
      FROM github_repositories
      INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
      WHERE github_pull_requests.action = 'opened'
      GROUP BY github_repositories.id
      ORDER BY pull_request_count desc")
  end
end
