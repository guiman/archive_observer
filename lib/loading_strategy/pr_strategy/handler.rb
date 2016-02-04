require 'loading_strategy/pr_strategy/language_handler'
require 'loading_strategy/pr_strategy/user_handler'
require 'loading_strategy/pr_strategy/repository_handler'
require 'loading_strategy/pr_strategy/pull_request_handler'

module LoadingStrategy
  module PRStrategy
    class Handler
      def initialize(data)
        @data = data
      end

      def language
        LanguageHandler.new(@data)
      end

      def user
        UserHandler.new(@data)
      end

      def repository
        RepositoryHandler.new(@data, language)
      end

      def pull_request
        PullRequestHandler.new(@data, repository, user)
      end

      def push_data
        OpenStruct.new(sql: nil)
      end
    end
  end
end
