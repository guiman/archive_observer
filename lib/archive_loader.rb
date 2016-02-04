require 'archive_extensions'
require 'loading_strategy'
require 'open-uri'
require 'zlib'
require 'yajl'

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
    push_inserts = []

    Yajl::Parser.parse(js) do |event|
      next unless LoadingStrategy::Chooser.can_be_parsed?(event)

      strategy = LoadingStrategy::Chooser.from_event(event)

      user_inserts << strategy.user.sql
      languages_inserts << strategy.language.sql
      repository_inserts << strategy.repository.sql
      pr_inserts << strategy.pull_request.sql
      push_inserts << strategy.push_data.sql
    end

    user_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    languages_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    repository_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    pr_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end

    push_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue
      end
    end
  end
end
