namespace :archiver do
  desc "update rankings"
  task :update_rankings => :environment do |t,args|
    ArchiveExtensions::RepositoryRankingUpdate.update
    ArchiveExtensions::UserRankingUpdate.update
  end

  desc "load archive into database"
  task :load_archive => :environment do |t, args|
    Dir["#{Rails.root}/archive_files/*.json"].each do |file_path|
      queued_file_path = file_path.gsub(/archive_files/,'archive_queued_files')
      File.rename file_path, queued_file_path

      ArchiveLoader.perform_async(queued_file_path)
    end
  end
end
