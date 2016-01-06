require 'rails_helper'

describe "All language activity broken down by month related to a user" do
  it "returns a list of the months  and in which the user has been active for X language" do
    user = GithubUser.create(login: "user_a")
    language = Language.create(name: "Ruby")
    repo = GithubRepository.create(full_name: "full/name", language: language)

    # Build some history for 3 months
    3.times.with_index do |_, i|
      month = i + 1
      month.times.with_index do |_, j|
        day = j + 1
        GithubPullRequest.create(github_user: user,
          github_repository: repo, action: "opened",
          event_timestamp: DateTime.parse("#{day}/#{month}/#{Time.now.year} 00:00:00"))
      end
    end

    expected_result = [
      { "month" => 1, "prs" => 1},
      { "month" => 2, "prs" => 2},
      { "month" => 3, "prs" => 3},
    ]

    expect(ArchiveExtensions::LanguageBreakdown.for(
      login: "user_a", language: "Ruby")).to eq(expected_result)
  end

  it "filters by year 2015" do
    user = GithubUser.create(login: "user_a")
    language = Language.create(name: "Ruby")
    repo = GithubRepository.create(full_name: "full/name", language: language)

    # Build some history for 3 months in 2015
    3.times.with_index do |_, i|
      month = i + 1
      month.times.with_index do |_, j|
        day = j + 1
        GithubPullRequest.create(github_user: user,
          github_repository: repo, action: "opened",
          event_timestamp: DateTime.parse("#{day}/#{month}/2015 00:00:00"))
      end
    end

    # Build some history for 3 months in 2016
    3.times.with_index do |_, i|
      month = i + 1
      month.times.with_index do |_, j|
        day = j + 1
        GithubPullRequest.create(github_user: user,
          github_repository: repo, action: "opened",
          event_timestamp: DateTime.parse("#{day}/#{month}/2016 00:00:00"))
      end
    end

    expected_result = [
      { "month" => 1, "prs" => 1},
      { "month" => 2, "prs" => 2},
      { "month" => 3, "prs" => 3},
    ]

    expect(ArchiveExtensions::LanguageBreakdown.for(
      login: "user_a", language: "Ruby", year: 2016)).to eq(expected_result)
  end
end
