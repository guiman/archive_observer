class UserRanking < ActiveRecord::Base
  belongs_to :github_user
  def ==(another_object)
    github_user == another_object.github_user &&
      pull_request_count == another_object.pull_request_count
  end
end
