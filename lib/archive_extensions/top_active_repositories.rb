module ArchiveExtensions
  class TopActiveRepositories
    def self.for(count: 5)
      results = GithubRepository.connection.select_all("
        SELECT github_repositories.id as id, count(github_pull_requests.id) as prs
        FROM github_repositories
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.action = 'opened'
        GROUP BY github_repositories.id
        ORDER BY prs desc
        LIMIT #{count}")

      ids = results.map { |res| res.fetch("id") }

      GithubRepository.where(id: ids)
    end
  end
end
