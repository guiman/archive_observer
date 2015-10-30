class RepositoryRanking < ActiveRecord::Base
  belongs_to :github_repository

  def ==(another_object)
    github_repository == another_object.github_repository &&
      pull_request_count == another_object.pull_request_count
  end
end
