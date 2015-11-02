namespace :archiver do
  desc "update rankings"
  task :update_rankings => :environment do |t,args|
    ArchiveExtensions::RepositoryRankingUpdate.update
    ArchiveExtensions::UserRankingUpdate.update
  end

  desc "load archive into database"
  task :load_archive => :environment do |t, args|
    date = Date.today
    hour = (Time.now - 1.hour).strftime('%H')
    date_and_hour = "#{date}-#{hour}"
    ArchiveLoader.perform(date_and_hour)
  end
end
