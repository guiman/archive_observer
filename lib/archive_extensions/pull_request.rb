module ArchiveExtensions
  class PullRequest
    def self.parse(data)
      language = self.parse_language(data)

      github_user = self.parse_user(data)
      github_repository = self.parse_repository(data, language)

      self.parse_pull_request(data, github_user, github_repository)
    end

    def self.parse_language(data)
      name = data.fetch("where").fetch("repo").fetch("language")
      Language.find_or_create_by(name: name)
    end

    def self.parse_user(data)
      login = data.fetch("who").fetch("login")
      github_user = GithubUser.find_by(login: login)
      return github_user unless github_user.nil?

      GithubUser.create(login: login,
        avatar_url: data.fetch("who").fetch("avatar_url"))
    end

    def self.parse_repository(data, language)
      repo_name = data.fetch("where").fetch("repo").fetch("name")
      repository = GithubRepository.where("full_name ILIKE ?", repo_name).first
      return repository unless repository.nil?

      GithubRepository.find_or_create_by(full_name: repo_name,
        language: language)
    end

    def self.parse_pull_request(data, user, repository)
      GithubPullRequest.create(github_repository: repository,
        github_user: user, event_timestamp: Time.parse(data.fetch("when")),
        action: data.fetch("what").fetch("action"),
        merged: data.fetch("what").fetch("merged"),
        original_id: data.fetch("original_id"))
    rescue ActiveRecord::RecordNotUnique
      # not doing anything here for now
    end
  end
end
