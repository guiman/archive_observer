require 'rails_helper'

describe "Top active developers" do
  it "returns a list of the top 3 developers and the number of PRs to them" do
    user_a = GithubUser.create(login: "user_a")
    user_b = GithubUser.create(login: "user_b")
    user_c = GithubUser.create(login: "user_c")

    repo_a = GithubRepository.create(full_name: "#{user_a.login}/name")
    3.times do
      GithubPullRequest.create(github_user: user_a, github_repository: repo_a, action: "opened")
    end

    repo_b = GithubRepository.create(full_name: "#{user_b.login}/name")
    2.times do
      GithubPullRequest.create(github_user: user_b, github_repository: repo_b, action: "opened")
    end

    repo_c = GithubRepository.create(full_name: "#{user_c.login}/name")
    GithubPullRequest.create(github_user: user_c, github_repository: repo_c, action: "opened")

    expected_response = [
      { "user" => user_a, "prs" => 3},
      { "user" => user_b, "prs" => 2},
      { "user" => user_c, "prs" => 1}
    ]

    expect(ArchiveExtensions::TopActiveDevelopers.for(count: 3)).to eq(expected_response)
  end
end
