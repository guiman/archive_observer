module ArchiveExtensions
  class UserRankingUpdate
    def self.update
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW user_rankings")
    end
  end
end
