module LoadingStrategy
  module PushStrategy
    class UserHandler
      TEMPLATE = "INSERT INTO github_users (login, created_at, updated_at) VALUES ('%{login}',now(),now())"

      def initialize(data)
        @data = data.fetch("actor")
      end

      def login
        @data.fetch("login")
      end

      def sql
        TEMPLATE % { login: login }
      end

      def create
        @ar_object = GithubUser.find_or_create_by(login: login)
      end

      def ar_object
        @ar_object
      end
    end
  end
end
