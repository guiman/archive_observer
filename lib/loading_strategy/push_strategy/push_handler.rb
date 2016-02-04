module LoadingStrategy
  module PushStrategy
    class PushHandler
      TEMPLATE = "INSERT INTO github_pushes (commit_count,original_id,event_timestamp,github_repository_id,created_at,updated_at) VALUES ('%{commit_count}', %{original_id}, '%{event_timestamp}', (SELECT id FROM github_repositories WHERE github_repositories.full_name = '%{repository_full_name}'), now(),now());"
      attr_reader :repository

      def initialize(data, repository)
        @data = data
        @repository = repository
      end

      def original_id
        @data.fetch("payload").fetch("push_id")
      end

      def commit_count
        @data.fetch("payload").fetch("distinct_size")
      end

      def event_timestamp
        @data.fetch("created_at")
      end

      def sql
        TEMPLATE % {
          repository_full_name: repository.full_name,
          commit_count: commit_count,
          original_id: original_id,
          event_timestamp: event_timestamp
        }
      end
    end
  end
end
