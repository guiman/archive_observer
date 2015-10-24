require 'rails_helper'

describe "Top active repositories" do
  it "returns a list of the top 5 repositories and the number of PRs to them" do
    user_a = GithubUser.create(login: "user_a")
    user_b = GithubUser.create(login: "user_b")

    5.times do |index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}")
      pos.times do
        GithubPullRequest.create(github_user: user_a, github_repository: repo, action: "opened")
      end
    end

    repos = []

    5.times do |index|
      pos = index + 10
      repo = GithubRepository.create(full_name: "full/b_name_#{pos}")
      repos << repo
      pos.times do
        GithubPullRequest.create(github_user: user_b, github_repository: repo, action: "opened")
      end
    end

    expected_response = [
      { "repo" => repos[4], "prs" => 14},
      { "repo" => repos[3], "prs" => 13},
      { "repo" => repos[2], "prs" => 12},
      { "repo" => repos[1], "prs" => 11},
      { "repo" => repos[0], "prs" => 10}
    ]

    expect(ArchiveExtensions::TopActiveRepositories.for(count: 5)).to eq(expected_response)
  end

  it "returns a list of the top 5 repositories in ruby and the number of PRs to them" do
    user_a = GithubUser.create(login: "user_a")
    ruby = Language.create(name: "ruby")
    javascript = Language.create(name: "javascript")
    repos = []

    5.times do |index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}", language: ruby)
      repos << repo
      pos.times do
        GithubPullRequest.create(github_user: user_a, github_repository: repo, action: "opened")
      end
    end

    repo = GithubRepository.create(full_name: "full/name_7", language: javascript)
    7.times do
      GithubPullRequest.create(github_user: user_a, github_repository: repo, action: "opened")
    end

    expected_response = [
      { "repo" => repos[4], "prs" => 5},
      { "repo" => repos[3], "prs" => 4},
      { "repo" => repos[2], "prs" => 3},
      { "repo" => repos[1], "prs" => 2},
      { "repo" => repos[0], "prs" => 1}
    ]

    expect(ArchiveExtensions::TopActiveRepositories.for(count: 5, language: ruby)).to eq(expected_response)
  end
end
