class GithubRepository < ActiveRecord::Base
  has_many :github_pull_requests
  belongs_to :language

  def partial_name
    full_name.split('/').last
  end

  def contributors
    GithubUser.joins(pull_requests: :github_repository).
      select("github_users.login, count(github_pull_requests.id) as prs, github_repositories.id").
      where("github_repositories.id = :repo_id", repo_id: self.id).
      group("github_users.login, github_repositories.id").
      order("prs desc").
      distinct
  end

  def all_contributors
    GithubUser.joins(pull_requests: :github_repository).
      select("github_users.login, count(github_pull_requests.id) as prs, github_repositories.id").
      where("github_repositories.full_name ~ '.*\/#{self.partial_name}$'").
      group("github_users.login, github_repositories.id").
      order("prs desc").
      distinct
  end
end
