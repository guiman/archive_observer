module ArchiveExtensions
  class TopActiveRepositories
    def self.for(count: 5, language: nil)
      query = RepositoryRanking.joins(:github_repository)
      query = query.where("github_repositories.language_id = ?", language.id) if language.present?
      results = query.limit(count).order("pull_request_count desc")

      results.inject([]) do |acc,result|
        repository = result.github_repository
        pr_count = result.pull_request_count
        acc << { "repo" => repository, "prs" => pr_count.to_i }
      end
    end
  end
end
