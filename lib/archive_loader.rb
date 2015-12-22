require 'archive_extensions'
require 'open-uri'
require 'zlib'
require 'yajl'

class ArchiveLoader
  def self.perform(timestamp)
    gz = open("http://data.githubarchive.org/#{timestamp}.json.gz")
    js = Zlib::GzipReader.new(gz).read

    user_insert_template = "INSERT INTO github_users (login, created_at, updated_at) VALUES ('%{login}',now(),now())"
    language_insert_template = "INSERT INTO languages (name,created_at,updated_at) VALUES ('%{name}', now(),now());"
    repository_insert_template = "INSERT INTO github_repositories (full_name,language_id,created_at,updated_at) VALUES ('%{full_name}', (SELECT id FROM languages WHERE languages.name ILIKE '%{repository_language}'), now(),now());"
    pr_insert_template = "INSERT INTO github_pull_requests (action,merged,original_id,event_timestamp,github_user_id, github_repository_id,created_at,updated_at) VALUES ('%{action}','%{merged}', %{original_id}, '%{event_timestamp}', (SELECT id FROM github_users WHERE github_users.login = '%{user_login}'), (SELECT id FROM github_repositories WHERE github_repositories.full_name = '%{repository_full_name}'), now(),now());"

    user_inserts = []
    languages_inserts = []
    repository_inserts = []
    pr_inserts = []

    Yajl::Parser.parse(js) do |event|
      unless event.fetch("type") == "PullRequestEvent" &&
        event.fetch("payload").fetch("action") == "opened"
        next
      end

      repo = event.fetch("payload").fetch("pull_request").fetch("head").fetch("repo")

      user_insert_data = {
        login: event.fetch("actor").fetch("login")
      }

      language_name = repo.fetch("language", "Unknown") || "Unknown"
      language_insert_data = {
        name: (language_name.empty? || language_name == "null")  ? "Unknown" : language_name
      }
      repository_insert_data = {
        full_name: repo.fetch("full_name"),
        repository_language: language_insert_data.fetch(:name)
      }
      pr_insert_data = {
        action: event.fetch("payload").fetch("action"),
        merged: event.fetch("payload").fetch("pull_request").fetch("merged"),
        user_login: user_insert_data.fetch(:login),
        repository_full_name: repository_insert_data.fetch(:full_name),
        original_id: event.fetch("payload").fetch("pull_request").fetch("id"),
        event_timestamp: event.fetch("payload").fetch("pull_request").fetch("updated_at")
      }

      user_inserts << user_insert_template % user_insert_data
      languages_inserts << language_insert_template % language_insert_data
      repository_inserts << repository_insert_template % repository_insert_data
      pr_inserts << pr_insert_template % pr_insert_data
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

    ArchiveExtensions::RepositoryRankingUpdate.update
    ArchiveExtensions::UserRankingUpdate.update
  end
end
