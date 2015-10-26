module ArchiveExtensions
  class Languages
    def self.for(github_login)
      user = GithubUser.find_by_login(github_login)

      results = Language.connection.select_all("
        SELECT languages.id as id, count(github_pull_requests.id) as prs
        FROM languages
        INNER JOIN github_repositories on github_repositories.language_id = languages.id
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened'
        GROUP BY languages.id
        ORDER BY prs desc")

      ids = results.map { |res| res.fetch("id") }

      languages = Language.where(id: ids)

      results.inject([]) do |acc, result|
        language = languages.detect { |lang| lang.id == result.fetch("id").to_i }
        pr_count = result.fetch("prs")
        acc << { "language" => language, "prs" => pr_count.to_i }
      end
    end
  end
end
