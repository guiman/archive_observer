module ArchiveExtensions
  class SimilarUsers
    def self.calculate(login: , language_threshold: 60.0, activity_threshold: 20.0, year: Time.now.year)
      # 1st find users that he is connected to (by the repos he contributes to)
      # 2nd calculate the language difference to those users
      # 3nd calculate the activity difference to those users
      # If the calculated difference is above a certain threshold
      # then add them to the results
      ArchiveExtensions::TopContributedRepositories.pr_for(login: login, count: 10).map do |contributed_repo|
        repo = contributed_repo.fetch("repo")
        repo.all_contributors.select do |contributor|
          contributor.login != login &&
            ArchiveExtensions::CompareUsers.calculate_language_similarity(user_a: login, user_b: contributor.login) >= language_threshold &&
            ArchiveExtensions::CompareUsers.calculate_activity_difference(user_a: login, user_b: contributor.login, year: year) <= activity_threshold
        end
      end.flatten.uniq { |user| user.login }
    end

    def self.calculate_new(login: , language_threshold: 60.0, activity_threshold: 20.0, year: Time.now.year, limit:, offset: 0)
      GithubUser.limit(limit).offset(offset).select do |user|
        user.login != login &&
          ArchiveExtensions::CompareUsers.calculate_language_similarity(user_a: login, user_b: user.login) >= language_threshold &&
          ArchiveExtensions::CompareUsers.calculate_activity_difference(user_a: login, user_b: user.login, year: year) <= activity_threshold
      end.flatten.uniq { |user| user.login }
    end
  end
end
