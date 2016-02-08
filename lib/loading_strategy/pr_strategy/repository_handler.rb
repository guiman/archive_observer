module LoadingStrategy
  module PRStrategy
    class RepositoryHandler
      TEMPLATE = "INSERT INTO github_repositories (full_name,fork,language_id,created_at,updated_at) VALUES ('%{full_name}', %{fork}, (SELECT id FROM languages WHERE languages.name ILIKE '%{repository_language}'), now(),now());"
      attr_reader :language

      def initialize(data, language)
        @data = data.fetch("payload").fetch("pull_request").fetch("head").fetch("repo")
        @language = language
      end

      def full_name
        @data.fetch("full_name")
      end

      def forked
        @data.fetch("fork")
      end

      def sql
        TEMPLATE % {
          full_name: full_name,
          fork: forked,
          repository_language: language.name
        }
      end

      def create
        @ar_object = GithubRepository.create(fork: forked, full_name: full_name,
          language: language.ar_object)
      rescue ActiveRecord::RecordNotUnique
        @ar_object = GithubRepository.find_by(full_name: full_name)
      end

      def ar_object
        @ar_object
      end
    end
  end
end
