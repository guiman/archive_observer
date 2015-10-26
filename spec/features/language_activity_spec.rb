require 'rails_helper'

describe "Language activity" do
  subject { ArchiveExtensions::LanguageActivity }
  it "returns list of pull requests for a user in a certain language" do
    user = GithubUser.create(login: "user_a")
    repo = GithubRepository.create(full_name: "full/name",
      language: Language.create(name: "lang_a"))

    prs = 3.times.inject([]) do |acc, index|
      acc << GithubPullRequest.create(github_user: user,
        github_repository: repo, action: "opened")
    end

    feature_result = subject.for(language: "lang_a", login: "user_a")

    expect(feature_result).to eq(prs)
    expect(prs.count).to eq(3)
  end

  it "doesn't consider other languages" do
    user = GithubUser.create(login: "user_a")
    Language.create(name: "lang_a")
    repo = GithubRepository.create(full_name: "full/name",
      language: Language.create(name: "lang_b"))

    2.times do
      GithubPullRequest.create(github_user: user,
        github_repository: repo, action: "opened")
    end

    feature_result = subject.for(language: "lang_a", login: "user_a")

    expect(feature_result).to be_empty
  end

  it "doesn't consider closed PRs" do
    user = GithubUser.create(login: "user_a")
    repo = GithubRepository.create(full_name: "full/name",
      language: Language.create(name: "lang_a"))

    2.times do
      GithubPullRequest.create(github_user: user,
        github_repository: repo, action: "closed")
    end

    feature_result = subject.for(language: "lang_a", login: "user_a")

    expect(feature_result).to be_empty
  end
end
