class GithubRepository < ActiveRecord::Base
  has_many :github_pull_requests
  belongs_to :language
end
