module ArchiveExtensions
  class SimilarUsers
    def self.calculate(login: , language_threshold: 20.0, year: Time.now.year, level: 1)
      # 1st find users that he is connected to (by the repos he contributes to)
      # 2nd calculate the language difference to those users
      # If the calculated difference is above a certain threshold
      # then add them to the results
      if level > 1
        similar = calculate_base(login: login, language_threshold: language_threshold, year: year)
        similar_level = similar.map do |similar_user|
          next if similar_user.login == login
          SimilarUsers.calculate(login: similar_user.login, language_threshold: language_threshold, year: year, level: level - 1)
        end.compact

        similar | similar_level
      else
        calculate_base(login: login, language_threshold: language_threshold, year: year)
      end.flatten
    end

    def self.calculate_base(login: , language_threshold: 20.0, year: Time.now.year)
      ArchiveExtensions::TopContributedRepositories.for(login: login, count: 5).map do |contributed_repo|
        repo = contributed_repo.fetch("repo")
        repo.all_contributors.select do |contributor|
          contributor.login != login && ArchiveExtensions::CompareUsers.
            calculate_language_difference(login, contributor.login) <= language_threshold
        end
      end.flatten.uniq { |user| user.login }
    end
  end
end
