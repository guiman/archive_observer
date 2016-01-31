require 'archive_extensions'
require 'open-uri'
require 'zlib'
require 'yajl'

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
end

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
end

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

class ArchiveLoader
  def self.perform(timestamp)
    url = "http://data.githubarchive.org/#{timestamp}.json.gz"
    p "Fetching #{url}"
    gz = open(url)
    js = Zlib::GzipReader.new(gz).read

    import_by_the_old_method(js)

    ArchiveExtensions::RepositoryRankingUpdate.update
    ArchiveExtensions::UserRankingUpdate.update
  end

  def self.import_by_the_old_method(js)
    user_inserts = []
    languages_inserts = []
    repository_inserts = []
    pr_inserts = []

    Yajl::Parser.parse(js) do |event|
      next unless event.fetch("type") == "PullRequestEvent" &&
        event.fetch("payload").fetch("action") == "opened"

      language = LanguageHandler.new(event)
      user = UserHandler.new(event)
      repository = RepositoryHandler.new(event, language)
      pull_request = PullRequestHandler.new(event, repository, user)

      user_inserts << user.sql
      languages_inserts << language.sql
      repository_inserts << repository.sql
      pr_inserts << pull_request.sql
    end

    user_inserts.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    languages_inserts.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    repository_inserts.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    pr_inserts.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end
  end
end
