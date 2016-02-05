require 'rails_helper'

describe ArchiveExtensions::UserActivity do
  describe ".pr_for" do
    context "user has no PR contributions" do
      it "returns a list of all prs for a user by month" do
        GithubUser.create(login: "guiman")
        expected_result = [0,0,0,0,0,0,0,0,0,0,0,0]
        expect(described_class.pr_for(login: "guiman")).to eq(expected_result)
      end
    end

    context "user has PR contributions" do
      it "returns a list of all prs for a user by month" do
        user = GithubUser.create(login: "guiman")
        repo = GithubRepository.create(full_name: "full/name")

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
        expected_result = [1,2,3,0,0,0,0,0,0,0,0,0]
        expect(described_class.pr_for(login: "guiman")).to eq(expected_result)
      end
    end
  end

  describe ".commit_for" do
    context "user has no commit contributions" do
      it "returns a list of all commits for a user by month" do
        GithubUser.create(login: "guiman")
        expected_result = [0,0,0,0,0,0,0,0,0,0,0,0]

        expect(described_class.commits_for(login: "guiman")).to eq(expected_result)
      end
    end

    context "user has commit contributions" do
      it "returns a list of all prs for a user by month" do
        user = GithubUser.create(login: "guiman")
        repo = GithubRepository.create(full_name: "full/name")

        # Build some history for 3 months
        3.times.with_index do |_, i|
          month = i + 1
          month.times.with_index do |_, j|
            day = j + 1
            GithubPush.create(github_user: user,
              github_repository: repo,
              commit_count: day,
              event_timestamp: DateTime.parse("#{day}/#{month}/#{Time.now.year} 00:00:00"))
          end
        end

        expected_result = [1,3,6,0,0,0,0,0,0,0,0,0]
        expect(described_class.commits_for(login: "guiman")).to eq(expected_result)
      end
    end
  end
end
