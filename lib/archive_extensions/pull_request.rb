module ArchiveExtensions
  class PullRequest
    def self.parse(data)
      language = Language.find_or_create_by(name: data.fetch("where").fetch("language"))
      github_user = GithubUser.find_or_create_by(login: data.fetch("who").fetch("login"),
        avatar_url: data.fetch("who").fetch("avatar_url"))
      github_repository = GithubRepository.find_or_create_by(full_name: data.fetch("where").fetch("repo"),
        language: language)

      if pr = GithubPullRequest.find_by(github_repository: github_repository, github_user: github_user, event_timestamp: Time.parse(data.fetch("when")))
        pr.update(event_timestamp: Time.parse(data.fetch("when")),
                 action: data.fetch("what").fetch("action"),
                 merged: data.fetch("what").fetch("merged"))
      else
        GithubPullRequest.create(github_repository: github_repository,
          github_user: github_user, event_timestamp: Time.parse(data.fetch("when")),
          action: data.fetch("what").fetch("action"), merged: data.fetch("what").fetch("merged"))
      end
    end
  end
end
