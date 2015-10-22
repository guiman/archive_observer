class GithubUser < ActiveRecord::Base
  has_many :pull_requests, class_name: "GithubPullRequest"
end
