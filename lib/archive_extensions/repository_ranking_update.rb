module ArchiveExtensions
  class RepositoryRankingUpdate
    def self.update
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW repository_rankings")
    end
  end
end
