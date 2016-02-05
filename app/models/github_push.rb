class GithubPush < ActiveRecord::Base
  belongs_to :github_repository
  belongs_to :github_user
end
