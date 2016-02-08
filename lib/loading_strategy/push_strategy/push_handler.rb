module LoadingStrategy
  module PushStrategy
    class PushHandler
      TEMPLATE = "INSERT INTO github_pushes (commit_count,original_id,event_timestamp,github_repository_id,github_user_id,created_at,updated_at) VALUES ('%{commit_count}', %{original_id}, '%{event_timestamp}', (SELECT id FROM github_repositories WHERE github_repositories.full_name = '%{repository_full_name}') , (SELECT id FROM github_users WHERE github_users.login = '%{user_login}'), now(),now());"
      attr_reader :repository, :user

      def initialize(data, repository, user)
        @data = data
        @repository = repository
        @user = user
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
          user_login: user.login,
          event_timestamp: event_timestamp
        }
      end

      def create
        @ar_object = GithubPush.create(commit_count: commit_count, original_id: original_id,
          github_user: user.ar_object, github_repository: repository.ar_object)
      rescue ActiveRecord::RecordNotUnique
        @ar_object = GithubPush.find_by(original_id: original_id)
      end
    end
  end
end
