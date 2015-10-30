module ArchiveExtensions
  class TopActiveDevelopers
    def self.for(count: 5)
      UserRanking.limit(count).order("pull_request_count desc")
    end
  end
end
