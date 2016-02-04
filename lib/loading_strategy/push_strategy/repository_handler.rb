module LoadingStrategy
  module PushStrategy
    class RepositoryHandler
      TEMPLATE = "INSERT INTO github_repositories (full_name,created_at,updated_at) VALUES ('%{full_name}', now(),now());"
      attr_reader :language

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
    end
  end
end
