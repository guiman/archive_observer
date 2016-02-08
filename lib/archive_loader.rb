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
  end

  def self.import_by_the_new_method(js)
    Yajl::Parser.parse(js) do |event|
      next unless LoadingStrategy::Chooser.can_be_parsed?(event)

      strategy = LoadingStrategy::Chooser.from_event(event)

      strategy.user.create
      strategy.language.create
      strategy.repository.create
      strategy.pull_request.create
      strategy.push_data.create
    end
  end

  def self.import_by_the_old_method(js)
    user_list = []
    languages_list = []
    repository_list = []
    pr_list = []
    push_list = []

    Yajl::Parser.parse(js) do |event|
      next unless LoadingStrategy::Chooser.can_be_parsed?(event)

      strategy = LoadingStrategy::Chooser.from_event(event)
      user_list << strategy.user
      languages_list << strategy.language
      repository_list << strategy.repository
      pr_list << strategy.pull_request
      push_list << strategy.push_data
    end

    users = user_list.map { |user| user.login }.uniq
    existing_users = GithubUser.where(login: users).pluck(:login)
    user_inserts = user_list.map { |user| !existing_users.include?(user.login) ? user.sql : nil }

    user_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue ActiveRecord::RecordNotUnique
      end
    end

    languages = languages_list.map { |language| language.name }.uniq
    existing_languages = Language.where(name: languages).pluck(:name)
    languages_inserts = languages_list.map { |lang| !existing_languages.include?(lang.name) ? lang.sql : nil }

    languages_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue ActiveRecord::RecordNotUnique
      end
    end

    repositories = repository_list.map { |repo| repo.full_name }.uniq
    existing_repositories = GithubRepository.where(full_name: repositories).pluck(:full_name)
    repository_inserts = repository_list.map { |repo| !existing_repositories.include?(repo.full_name) ? repo.sql : nil }

    repository_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue ActiveRecord::RecordNotUnique
      end
    end

    pull_requests = pr_list.map { |pr| pr.original_id }.uniq
    existing_prs = GithubPullRequest.where(original_id: pull_requests).pluck(:original_id)
    pr_inserts = pr_list.map { |pr| !existing_prs.include?(pr.original_id) ? pr.sql : nil }

    pr_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue ActiveRecord::RecordNotUnique
      end
    end

    pushes = push_list.map { |push| push.original_id }.uniq
    existing_pushes = GithubPush.where(original_id: pushes).pluck(:original_id)
    push_inserts = push_list.map { |push| !existing_pushes.include?(push.original_id) ? push.sql : nil }

    push_inserts.compact.each do |insert|
      begin
        ActiveRecord::Base.connection.execute(insert)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end
end
