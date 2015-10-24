module ArchiveExtensions
  class TopActiveDevelopers
    def self.for(count: 5)
      results = GithubRepository.connection.select_all("
          SELECT github_users.id as id, count(github_pull_requests.id) as prs
          FROM github_users
          INNER JOIN github_pull_requests on github_pull_requests.github_user_id = github_users.id
          WHERE github_pull_requests.action = 'opened'
          GROUP BY github_users.id
          ORDER BY prs desc
          LIMIT #{count}")

      ids = results.map { |res| res.fetch("id") }

      users = GithubUser.where(id: ids)

      results.inject([]) do |acc,result|
        user = users.detect { |usr| usr.id == result.fetch("id").to_i }
        pr_count = result.fetch("prs")
        acc << { "user" => user, "prs" => pr_count.to_i }
      end
    end
  end
end
