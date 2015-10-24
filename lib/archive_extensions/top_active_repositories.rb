module ArchiveExtensions
  class TopActiveRepositories
    def self.for(count: 5, language: nil)
      if language.present?
        results = GithubRepository.connection.select_all("
          SELECT github_repositories.id as id, count(github_pull_requests.id) as prs
          FROM github_repositories
          INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
          INNER JOIN languages on github_repositories.language_id = languages.id
          WHERE github_pull_requests.action = 'opened' and language_id = #{language.id}
          GROUP BY github_repositories.id
          ORDER BY prs desc
          LIMIT #{count}")
      else
        results = GithubRepository.connection.select_all("
          SELECT github_repositories.id as id, count(github_pull_requests.id) as prs
          FROM github_repositories
          INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
          WHERE github_pull_requests.action = 'opened'
          GROUP BY github_repositories.id
          ORDER BY prs desc
          LIMIT #{count}")
      end

      ids = results.map { |res| res.fetch("id") }

      repositories = GithubRepository.where(id: ids)

      results.inject([]) do |acc,result|
        repository = repositories.detect { |repo| repo.id == result.fetch("id").to_i }
        pr_count = result.fetch("prs")
        acc << { "repo" => repository, "prs" => pr_count.to_i }
      end
    end
  end
end
