require 'loading_strategy/push_strategy/user_handler'
require 'loading_strategy/push_strategy/push_handler'
require 'loading_strategy/push_strategy/repository_handler'

module LoadingStrategy
  module PushStrategy
    class Handler
      def initialize(data)
        @data = data
      end

      def language
        OpenStruct.new(sql: nil, create: nil)
      end

      def user
        UserHandler.new(@data)
      end

      def repository
        RepositoryHandler.new(@data)
      end

      def push_data
        PushHandler.new(@data, repository, user)
      end

      def pull_request
        OpenStruct.new(sql: nil, create: nil)
      end
    end
  end
end
