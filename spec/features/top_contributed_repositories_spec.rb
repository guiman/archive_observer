require 'rails_helper'

describe "Top contributed repositories" do
  it "returns a list of the top 5 repositories and the number of PRs to them" do
    user = GithubUser.create(login: "user_a")

    5.times do |index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}")
      pos.times do
        GithubPullRequest.create(github_user: user, github_repository: repo, action: "opened")
      end
    end

    # This is the one that should not appear
    repo = GithubRepository.create(full_name: "full/name_6")
    GithubPullRequest.create(github_user: user, github_repository: repo)

    expected_result = [
      { "name" => "full/name_5", "prs" => 5},
      { "name" => "full/name_4", "prs" => 4},
      { "name" => "full/name_3", "prs" => 3},
      { "name" => "full/name_2", "prs" => 2},
      { "name" => "full/name_1", "prs" => 1}
    ]

    expect(ArchiveExtensions::TopContributedRepositories.for(count: 5, login: "user_a")).to eq(expected_result)
  end
end
