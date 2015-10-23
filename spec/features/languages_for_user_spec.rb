require 'rails_helper'

describe "All languages related to a user" do
  it "returns a list of all the languages a user is involved in and the number of prs to them" do
    user = GithubUser.create(login: "user_a")

    5.times do |index|
      pos = index + 1
      language = Language.create(name: "lang_#{pos}")
      repo = GithubRepository.create(full_name: "full/name_#{pos}", language: language)
      pos.times do
        GithubPullRequest.create(github_user: user, github_repository: repo, action: "opened")
      end
    end

    expected_result = [
      { "name" => "lang_5", "prs" => 5},
      { "name" => "lang_4", "prs" => 4},
      { "name" => "lang_3", "prs" => 3},
      { "name" => "lang_2", "prs" => 2},
      { "name" => "lang_1", "prs" => 1}
    ]

    expect(ArchiveExtensions::Languages.for("user_a")).to eq(expected_result)
  end
end
