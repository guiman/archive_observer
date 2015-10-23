namespace :archiver do
  desc "load archive into database"
  task :load_archive => :environment do |t, args|
    require 'logger'
    require 'ostruct'

    logger = Logger.new(Rails.root.join('log', 'load_archive.log'))
    logger.level = Logger::DEBUG

    Dir["#{Rails.root}/archive_files/*.json"].each do |file_path|
      logger.info("Now processing #{file_path}")
      File.open(file_path).each_line do |line|
        clean_line = line.gsub(/\n/, '')
        pull_request = JSON.parse(clean_line)
        ArchiveExtensions::PullRequest.parse(pull_request)
      end
      processed_file_path = file_path.gsub(/archive_files/,'archive_processed_files')
      File.rename file_path, processed_file_path
    end
  end
end
