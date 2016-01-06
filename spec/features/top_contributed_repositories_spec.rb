require 'rails_helper'

describe "Top contributed repositories" do
  it "returns a list of the top 5 repositories and the number of PRs to them" do
    user = GithubUser.create(login: "user_a")
    repos = []

    5.times do |index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}")
      repos << repo
      pos.times do
        GithubPullRequest.create(github_user: user, github_repository: repo,
          action: "opened", event_timestamp: DateTime.parse("1/1/#{Time.now.year} 00:00:00"))
      end
    end

    # This is the one that should not appear
    repo = GithubRepository.create(full_name: "full/name_6")
    GithubPullRequest.create(github_user: user, github_repository: repo)

    expected_response = [
      { "repo" => repos[4], "prs" => 5},
      { "repo" => repos[3], "prs" => 4},
      { "repo" => repos[2], "prs" => 3},
      { "repo" => repos[1], "prs" => 2},
      { "repo" => repos[0], "prs" => 1}
    ]
    expect(ArchiveExtensions::TopContributedRepositories.for(count: 5, login: "user_a")).to eq(expected_response)
  end

  it "returns a list of the top 5 repositories and the number of PRs to them for 2015" do
    user = GithubUser.create(login: "user_a")
    repos = []

    5.times do |index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}")
      repos << repo
      pos.times do
        GithubPullRequest.create(github_user: user, github_repository: repo,
          action: "opened", event_timestamp: DateTime.parse("1/1/2015 00:00:00"))
      end
    end

    # This is the one that should not appear
    repo = GithubRepository.create(full_name: "full/name_6")
    GithubPullRequest.create(github_user: user, github_repository: repo,
      action: "opened", event_timestamp: DateTime.parse("1/1/2016 00:00:00"))

    expected_response = [
      { "repo" => repos[4], "prs" => 5},
      { "repo" => repos[3], "prs" => 4},
      { "repo" => repos[2], "prs" => 3},
      { "repo" => repos[1], "prs" => 2},
      { "repo" => repos[0], "prs" => 1}
    ]
    expect(ArchiveExtensions::TopContributedRepositories.for(count: 5, login: "user_a", year: 2015)).to eq(expected_response)
  end
end
