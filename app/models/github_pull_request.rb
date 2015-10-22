class GithubPullRequest < ActiveRecord::Base
  belongs_to :github_user
  belongs_to :github_repository
end
