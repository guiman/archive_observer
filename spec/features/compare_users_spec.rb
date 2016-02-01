require 'rails_helper'

describe "Comparing users" do
  describe ".calculate" do
    it "returns 0 difference between a and b" do
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

      user = GithubUser.create(login: "user_b")

      languages = 3.times.inject({}) do |acc, index|
        pos = index + 1

        language = Language.find_by(name: "lang_#{pos}")
        acc[pos] = language

        repo = GithubRepository.find_by(full_name: "full/name_#{pos}")
        pos.times do
          GithubPullRequest.create(github_user: user,
                                   github_repository: repo, action: "opened")
        end

        acc
      end

      difference = ArchiveExtensions::CompareUsers.calculate_difference("user_a", "user_b")
      expect(difference.fetch(:language_difference)).to eq(0.0)
    end

    it "returns 100 difference between a and b" do
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

      user = GithubUser.create(login: "user_b")

      languages = 3.times.inject({}) do |acc, index|
        pos = index + 1

        language = Language.create(name: "lang_b_#{pos}")
        acc[pos] = language

        repo = GithubRepository.create(full_name: "full/name_b_#{pos}", language: language)
        pos.times do
          GithubPullRequest.create(github_user: user,
                                   github_repository: repo, action: "opened")
        end

        acc
      end

      difference = ArchiveExtensions::CompareUsers.calculate_difference("user_a", "user_b")
      expect(difference.fetch(:language_difference)).to eq(100.0)
    end
  end
end
