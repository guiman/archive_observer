module LoadingStrategy
  module PushStrategy
    class RepositoryHandler
      TEMPLATE = "INSERT INTO github_repositories (full_name,created_at,updated_at) VALUES ('%{full_name}', now(),now());"

      def initialize(data)
        @data = data.fetch("repo")
      end

      def full_name
        @data.fetch("name")
      end

      def sql
        TEMPLATE % {
          full_name: full_name
        }
      end

      def create
        @ar_object = GithubRepository.find_or_create_by(full_name: full_name)
      end

      def ar_object
        @ar_object
      end
    end
  end
end
