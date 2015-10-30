module ArchiveExtensions
  class TopActiveRepositories
    def self.for(count: 5, language: nil)
      query = RepositoryRanking.joins(:github_repository)
      query = query.where("github_repositories.language_id = ?", language.id) if language.present?
      query.limit(count).order("pull_request_count desc")
    end
  end
end
