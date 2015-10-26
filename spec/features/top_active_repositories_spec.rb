require 'rails_helper'

describe "Top active repositories" do
  subject { ArchiveExtensions::TopActiveRepositories }
  it "returns a list of the top 3 repositories and the number of PRs to them" do
    user_a = GithubUser.create(login: "user_a")
    ruby = Language.create(name: "ruby")

    # we will create 4 repos with each having 4, 3, 2 and 1 opened PRs
    repos = create_repositories_with_prs(count: 4,
      language: ruby, user: user_a, repo_status: "opened")

    expected_response = [
      { "repo" => repos[3], "prs" => 4},
      { "repo" => repos[2], "prs" => 3},
      { "repo" => repos[1], "prs" => 2}
    ]

    expect(subject.for(count: 3)).to eq(expected_response)
  end

  it "returns a list of the top 3 repositories in ruby and the number of PRs to them" do
    user_a = GithubUser.create(login: "user_a")
    ruby = Language.create(name: "ruby")
    javascript = Language.create(name: "javascript")

    # we will create 4 repos with each having 4, 3, 2 and 1 opened PRs
    repos = create_repositories_with_prs(count: 4,
      language: ruby, user: user_a, repo_status: "opened")

    # here we create lots of activity on other language and make sure
    # it wont appear
    create_repositories_with_prs(count: 7,
      language: javascript, user: user_a, repo_status: "opened")

    expected_response = [
      { "repo" => repos[3], "prs" => 4},
      { "repo" => repos[2], "prs" => 3},
      { "repo" => repos[1], "prs" => 2},
    ]

    expect(subject.for(count: 3, language: ruby)).to eq(expected_response)
  end

  def create_repositories_with_prs(count:,language:,user:,repo_status:)
    count.times.inject([]) do |acc, index|
      pos = index + 1
      repo = GithubRepository.create(full_name: "full/name_#{pos}", language: language)
      pos.times do
        GithubPullRequest.create(github_user: user,
          github_repository: repo, action: repo_status)
      end

      acc << repo
    end
  end
end
