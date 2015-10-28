module ArchiveExtensions
  class RepositoryRankingUpdate
    def self.update
      # First create new entries for the new repositories
      ActiveRecord::Base.connection.execute("
        INSERT INTO repository_rankings (github_repository_id, pull_request_count)
        SELECT github_repositories.id as id, 0 as pull_request_count
        FROM github_repositories
        LEFT JOIN repository_rankings on repository_rankings.github_repository_id = github_repositories.id
        WHERE repository_rankings.github_repository_id IS NULL")

      # Now update the PRs count
      ActiveRecord::Base.connection.execute("
        UPDATE repository_rankings
        SET pull_request_count = calculation.prs
        FROM
          (
            SELECT github_repositories.id as id, count(github_pull_requests.id) as prs
            FROM github_repositories
            INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
            WHERE github_pull_requests.action = 'opened'
            GROUP BY github_repositories.id
            ORDER BY prs desc
          ) as calculation
        WHERE
          calculation.id = repository_rankings.github_repository_id")
    end
  end
end
