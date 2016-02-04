module LoadingStrategy
  module PRStrategy
    class LanguageHandler
      TEMPLATE = "INSERT INTO languages (name,created_at,updated_at) VALUES ('%{name}', now(),now());"

      def initialize(data)
        @data = data.fetch("payload").fetch("pull_request").fetch("head").fetch("repo")
      end

      def name
        language_name = @data.fetch("language", "Unknown") || "Unknown"
        (language_name.empty? || language_name == "null")  ? "Unknown" : language_name
      end

      def sql
        TEMPLATE % { name: name }
      end
    end
  end
end
