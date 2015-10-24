namespace :archiver do
  desc "load archive into database"
  task :load_archive => :environment do |t, args|
    Dir["#{Rails.root}/archive_files/*.json"].each do |file_path|
      ArchiveLoader.perform_async(file_path)
    end
  end
end
