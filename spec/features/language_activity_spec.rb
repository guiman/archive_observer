require 'rails_helper'

describe "Language activity" do
  it "returns list of pull requests for a user in a certain language" do
    user = GithubUser.create(login: "user_a")
    language = Language.create(name: "lang_5")
    repo = GithubRepository.create(full_name: "full/name_5", language: language)
    prs = []

    3.times do
      prs << GithubPullRequest.create(github_user: user, github_repository: repo, action: "opened")
    end

    2.times do
      GithubPullRequest.create(github_user: user, github_repository: repo, action: "closed")
    end

    4.times do |index|
      pos = index + 1
      language = Language.create(name: "lang_#{pos}")
      repo = GithubRepository.create(full_name: "full/name_#{pos}", language: language)
      pos.times do
        GithubPullRequest.create(github_user: user, github_repository: repo, action: "opened")
      end
    end

    feature_result = ArchiveExtensions::LanguageActivity.for(language: "lang_5", login: "user_a")

    expect(feature_result).to eq(prs)
    expect(prs.count).to eq(3)
  end
end
