module ArchiveExtensions
  class LanguageBreakdown
    def self.pr_for(login:, language:, year: Time.now.year)
      language = Language.find_by_name(language)
      user = GithubUser.find_by_login(login)

      results = Language.connection.select_all("
        SELECT count(github_pull_requests.id) as prs, Extract(month from github_pull_requests.event_timestamp) as month
        FROM languages
        INNER JOIN github_repositories on github_repositories.language_id = languages.id
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened' AND languages.id = #{language.id} AND Extract(year from github_pull_requests.event_timestamp) = '#{year}'
        GROUP BY month
        ORDER BY month asc")

      results.map do |result|
        result["prs"] = result["prs"].to_i
        result["month"] = result["month"].to_i
        result
      end
    end
  end
end
