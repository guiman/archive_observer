require 'archive_extensions'

class ArchiveLoader
  include Sidekiq::Worker
  def perform(file)
    File.open(file).each_line do |line|
      clean_line = line.gsub(/\n/, '')
      pull_request = JSON.parse(clean_line)
      ArchiveExtensions::PullRequest.parse(pull_request)
    end

    processed_file_path = file.gsub(/archive_files/,'archive_processed_files')
    File.rename file, processed_file_path
  end
end
