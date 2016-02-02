module ArchiveExtensions
  class SimilarUsers
    def self.calculate(login: , language_threshold: 20.0, activity_threshold: 1, year: Time.now.year)
      # 1st find users that he is connected to (by the repos he contributes to)
      # 2nd calculate the language difference to those users
      # If the calculated difference is above a certain threshold
      # then add them to the results
      ArchiveExtensions::TopContributedRepositories.for(login: login, count: 5).map do |contributed_repo|
        repo = contributed_repo.fetch("repo")
        repo.all_contributors.select do |contributor|
          language_difference = ArchiveExtensions::CompareUsers.calculate_language_difference(login, contributor.login)
          activity_difference = ArchiveExtensions::CompareUsers.calculate_activity_difference(login, contributor.login)
          contributor.login != login &&
            language_difference <= language_threshold &&
            activity_difference <= activity_threshold
        end
      end.flatten.uniq { |user| user.login }
    end
  end
end
