module ArchiveExtensions
  class LanguageActivity
    def self.for(language:,login:)
      user = GithubUser.find_by_login(login)
      language = Language.find_by_name(language)

      GithubPullRequest.
        joins(:github_repository).
        joins(github_repository: :language).
        where("github_pull_requests.github_user_id = :user_id and languages.id = :language_id and github_pull_requests.action = 'opened'", user_id: user.id, language_id: language.id)
    end
  end
end
