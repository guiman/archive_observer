require 'big_query'

module ArchiveExtensions
  class UserActivity
    def self.pr_for(login:, year: Time.now.year)
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

    def self.commits_for(login:, year: Time.now.year)
      opts = {}
      opts['client_id']     = '780353173605-jqo4f4kk1eq8vtf4delnjdo76e27uo31.apps.googleusercontent.com'
      opts['service_email'] = 'archiveobserver@alvarola.iam.gserviceaccount.com'
      opts['key']           = File.join(Rails.root, 'alvarola-27993c059cb7.p12')
      opts['project_id']    = 'alvarola'
      opts['dataset']       = 'githubarchive'

      bq = BigQuery::Client.new(opts)

      results = bq.query("SELECT count(id) as commits, MONTH(created_at) as month, actor.login
        FROM TABLE_DATE_RANGE([githubarchive:day.events_],
            TIMESTAMP('#{year}-01-01'),
            TIMESTAMP('#{year}-12-31')
          )
        WHERE type = 'PushEvent' and actor.login = '#{login}'
        GROUP BY actor.login, month
        ORDER BY month asc")

      (1..12).to_a.map do |month|
        value = results.fetch("rows").detect do |result|
          result.fetch("f")[1].fetch("v").to_i == month
        end
        value ? value.fetch("f").first.fetch("v").to_i : 0
      end
    end
  end
end
