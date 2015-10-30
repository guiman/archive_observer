module ArchiveExtensions
  class TopActiveDevelopers
    def self.for(count: 5)
      results = UserRanking.limit(count).order("pull_request_count desc")

      results.inject([]) do |acc,result|
        user = result.github_user
        pr_count = result.pull_request_count
        acc << { "user" => user, "prs" => pr_count }
      end
    end
  end
end
