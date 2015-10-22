require 'rails_helper'

describe ArchiveExtensions::PullRequest do
  describe ".parse" do
    it "creates user, repo, language and pull request data" do
      sample_data = {
        "who"=>{
          "id"=>2100512,
          "login"=>"gizak",
          "gravatar_id"=>"",
          "url"=>"https://api.github.com/users/gizak",
          "avatar_url"=>"https://avatars.githubusercontent.com/u/2100512?"
        },
        "where"=>{
          "repo"=>"alytvynov/termui",
          "language"=>"Go"
        },
        "when"=>"2015-10-21T01:59:56Z",
        "what"=>{
          "action"=>"closed",
          "merged"=>true
        }
      }

      described_class.parse(sample_data)

      language = Language.find_by_name("Go")
      repository = GithubRepository.find_by_full_name("alytvynov/termui")
      user = GithubUser.find_by(login: "gizak")
      pull_request = GithubPullRequest.find_by_github_user_id(user.id)

      expect(language).not_to be_nil

      expect(user).not_to be_nil
      expect(user.pull_requests)

      expect(repository).not_to be_nil
      expect(repository.language).to eq(language)

      expect(pull_request).not_to be_nil
      expect(pull_request.github_user).to eq(user)
      expect(pull_request.github_repository).to eq(repository)
    end

    it "creates user, repo, language and pull request data" do
      sample_data_1 = {
        "who"=>{
          "id"=>2100512,
          "login"=>"gizak",
          "gravatar_id"=>"",
          "url"=>"https://api.github.com/users/gizak",
          "avatar_url"=>"https://avatars.githubusercontent.com/u/2100512?"
        },
        "where"=>{
          "repo"=>"alytvynov/termui",
          "language"=>"Go"
        },
        "when"=>"2015-10-21T01:59:56Z",
        "what"=>{
          "action"=>"closed",
          "merged"=>true
        }
      }

      sample_data_2 = {
        "who"=>{
          "id"=>2100512,
          "login"=>"gizak",
          "gravatar_id"=>"",
          "url"=>"https://api.github.com/users/gizak",
          "avatar_url"=>"https://avatars.githubusercontent.com/u/2100512?"
        },
        "where"=>{
          "repo"=>"alytvynov/termui",
          "language"=>"Go"
        },
        "when"=>"2015-10-21T01:58:56Z",
        "what"=>{
          "action"=>"closed",
          "merged"=>true
        }
      }

      described_class.parse(sample_data_1)
      described_class.parse(sample_data_2)

      expect(Language.count).to eq(1)
      expect(GithubUser.count).to eq(1)
      expect(GithubRepository.count).to eq(1)
      expect(GithubPullRequest.count).to eq(2)
    end

    it "creates user, repo, language and pull request data" do
      sample_data_1 = {
        "who"=>{
          "id"=>2100512,
          "login"=>"gizak",
          "gravatar_id"=>"",
          "url"=>"https://api.github.com/users/gizak",
          "avatar_url"=>"https://avatars.githubusercontent.com/u/2100512?"
        },
        "where"=>{
          "repo"=>"alytvynov/termui",
          "language"=>"Go"
        },
        "when"=>"2015-10-21T01:59:56Z",
        "what"=>{
          "action"=>"closed",
          "merged"=>true
        }
      }

      described_class.parse(sample_data_1)
      described_class.parse(sample_data_1)

      expect(Language.count).to eq(1)
      expect(GithubUser.count).to eq(1)
      expect(GithubRepository.count).to eq(1)
      expect(GithubPullRequest.count).to eq(1)
    end
  end
end
