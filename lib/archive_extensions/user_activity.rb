module ArchiveExtensions
  class UserActivity
    def self.for(login:, year: Time.now.year)
      user = GithubUser.find_by_login(login)

      results = GithubUser.connection.select_all("
        SELECT count(github_pull_requests.id) as prs, Extract(month from github_pull_requests.event_timestamp) as month
        FROM github_users
        INNER JOIN github_pull_requests on github_pull_requests.github_user_id = github_users.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened' AND Extract(year from github_pull_requests.event_timestamp) = '#{year}'
        GROUP BY month
        ORDER BY month asc")

      (1..12).to_a.map do |month|
        value = results.detect { |result| result.fetch("month").to_i == month }
        value ? value.fetch("prs").to_i : 0
      end
    end
  end
end
