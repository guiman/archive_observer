module ArchiveExtensions
  class Languages
    def self.for(github_login)
      user = GithubUser.find_by_login(github_login)

      results = Language.connection.select_all("
        SELECT languages.name as name, count(github_pull_requests.id) as prs
        FROM languages
        INNER JOIN github_repositories on github_repositories.language_id = languages.id
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened'
        GROUP BY languages.name
        ORDER BY prs desc")

      results.map do |result|
        result["prs"] = result["prs"].to_i
        result
      end
    end
  end
end
