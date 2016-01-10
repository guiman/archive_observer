namespace :archiver do
  desc "update rankings"
  task :update_rankings => :environment do |t,args|
    ArchiveExtensions::RepositoryRankingUpdate.update
    ArchiveExtensions::UserRankingUpdate.update
  end

  desc "load archive into database"
  task :load_archive => :environment do |t, args|
    date = Date.today
    hour = (Time.now - 2.hour).strftime('%H')
    date_and_hour = "#{date}-#{hour}"
    ArchiveLoader.perform(date_and_hour)
  end

  desc "add location to users"
  task :add_location, [:github_token] => :environment do |t, args|
    client = Octokit::Client.new({ access_token: args[:github_token] })
    limit_reached = false

    GithubUser.where(reachable: true, location: nil).each do |user|
      begin
        ArchiveUserLocation.update(user, client)
      rescue Octokit::TooManyRequests
        limit_reached = true
      end

      break if limit_reached
    end
  end
end
