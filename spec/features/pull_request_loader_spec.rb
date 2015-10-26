require 'rails_helper'

describe ArchiveExtensions::PullRequest do
  let(:data) do
    JSON.parse({
      "who":{
        "id":898523,
        "login":"afaur",
        "gravatar_id":"",
        "url":"https://api.github.com/users/afaur",
        "avatar_url":"https://avatars.githubusercontent.com/u/898523?"
      },
      "original_id":48271645,
      "where":{
        "repo":{
          "name":"afaur/Elixir-Slack",
          "language":"Elixir",
          "fork":true
        }
      },
      "when":"2015-10-21T00:00:00Z",
      "what":{
        "action":"reopened",
        "merged":false
      }
    }.to_json)
  end

  it "creates all data if non of that exists" do
    described_class.parse(data)

    expect(GithubPullRequest.count).to eq(1)
    expect(Language.count).to eq(1)
    expect(GithubUser.count).to eq(1)
  end

  describe ".parse_language" do
    it "creates a language when it doesn't exist" do
      expect do
        described_class.parse_language(data)
      end.to change { Language.count }.by(1)
    end

    it "returns the existing language" do
      language = Language.create(name: "Elixir")

      expect(described_class.parse_language(data)).to eq(language)
    end
  end

  describe ".parse_user" do
    it "creates a user when it doesn't exist" do
      expect do
        described_class.parse_user(data)
      end.to change { GithubUser.count }.by(1)
    end

    it "returns the existing user" do
      user = GithubUser.create(login: "afaur")

      expect(described_class.parse_user(data)).to eq(user)
    end
  end

  describe ".parse_repository" do
    it "creates a reposiory when it doesn't exist" do
      language = Language.create(name: "Elixir")

      expect do
        described_class.parse_repository(data, language)
      end.to change { GithubRepository.count }.by(1)
    end

    it "returns the existing repository" do
      language = Language.create(name: "Elixir")
      repository = GithubRepository.create(full_name: "afaur/Elixir-Slack",
        language: language)

      expect(described_class.parse_repository(data, language)).to eq(repository)
    end
  end

  describe ".parse_pull_request" do
    it "creates a pull request when it doesn't exist" do
      language = Language.create(name: "Elixir")
      repository = GithubRepository.create(full_name: "afaur/Elixir-Slack",
        language: language)
      user = GithubUser.create(login: "afaur")

      expect do
        described_class.parse_pull_request(data, user, repository)
      end.to change { GithubPullRequest.count }.by(1)
    end

    xit "updates the existing repository" do
    end
  end
end
