module LoadingStrategy
  module PRStrategy
    class PullRequestHandler
      TEMPLATE = "INSERT INTO github_pull_requests (action,merged,original_id,event_timestamp,github_user_id, github_repository_id,created_at,updated_at) VALUES ('%{action}','%{merged}', %{original_id}, '%{event_timestamp}', (SELECT id FROM github_users WHERE github_users.login = '%{user_login}'), (SELECT id FROM github_repositories WHERE github_repositories.full_name = '%{repository_full_name}'), now(),now());"
      attr_reader :user, :repository

      def initialize(data, repository, user)
        @data = data.fetch("payload")
        @repository = repository
        @user = user
      end

      def action
        @data.fetch("action")
      end

      def merged?
        @data.fetch("pull_request").fetch("merged")
      end

      def original_id
        @data.fetch("pull_request").fetch("id")
      end

      def event_timestamp
        @data.fetch("pull_request").fetch("updated_at")
      end

      def sql
        TEMPLATE % {
          action: action,
          merged: merged?,
          user_login: user.login,
          repository_full_name: repository.full_name,
          original_id: original_id,
          event_timestamp: event_timestamp
        }
      end
    end
  end
end
