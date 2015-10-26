require 'rails_helper'

describe "All languages related to a user" do
  it "returns a list of all the languages a user is involved in and the number of prs to them" do
    user = GithubUser.create(login: "user_a")

    languages = 3.times.inject({}) do |acc, index|
      pos = index + 1

      language = Language.create(name: "lang_#{pos}")
      acc[pos] = language

      repo = GithubRepository.create(full_name: "full/name_#{pos}", language: language)
      pos.times do
        GithubPullRequest.create(github_user: user,
          github_repository: repo, action: "opened")
      end

      acc
    end

    expected_result = [
      { "language" => languages[3], "prs" => 3},
      { "language" => languages[2], "prs" => 2},
      { "language" => languages[1], "prs" => 1}
    ]

    expect(ArchiveExtensions::Languages.for("user_a")).to eq(expected_result)
  end

  it "doesn't consider closed PRs" do
    user = GithubUser.create(login: "user_a")

    language = Language.create(name: "lang_a")
    repo = GithubRepository.create(full_name: "full/name", language: language)
    GithubPullRequest.create(github_user: user,
      github_repository: repo, action: "closed")

    expect(ArchiveExtensions::Languages.for("user_a")).to be_empty
  end
end
