namespace :archiver do
  desc "update rankings"
  task :update_rankings => :environment do |t,args|
    ArchiveExtensions::RepositoryRankingUpdate.update
  end

  desc "load archive into database"
  task :load_archive, [:date_and_hour] => :environment do |t, args|
    if args[:date_and_hour]
      date_and_hour = args[:date_and_hour]
    else
      date = Date.today
      hour = (Time.now - 2.hour).strftime('%H')
      date_and_hour = "#{date}-#{hour}"
    end

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

  desc "add linkedin_link to users"
  task :add_linkedin_link => :environment do |t, args|
    GithubUser.where(reachable: true, linkedin_link: nil).limit(2000).each do |user|
      begin
        linkedin_profile = LinkedinProfile.new(user.login)

        link = linkedin_profile.verify_link ? linkedin_profile.link : "not_available"

        user.update(linkedin_link: link)
      rescue Excention
      end
    end
  end
end
