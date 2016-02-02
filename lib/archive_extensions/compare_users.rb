require 'descriptive_statistics'

module ArchiveExtensions
  class CompareUsers
    COMPARED_LANGUAGES = 4

    def self.calculate_language_difference(user_a, user_b)
      # Compare languages
      user_a_languages = ArchiveExtensions::Languages.for(user_a).
        first(COMPARED_LANGUAGES).map {|x| x.fetch("language").name }
      user_b_languages = ArchiveExtensions::Languages.for(user_b).
        first(COMPARED_LANGUAGES).map {|x| x.fetch("language").name }

      ((user_a_languages - user_b_languages).count.to_f / user_a_languages.count.to_f) * Float(100.0)
    end

    def self.calculate_activity_difference(user_a, user_b)
      user_a_activity = ArchiveExtensions::UserActivity.for(login: user_a)
      user_b_activity = ArchiveExtensions::UserActivity.for(login: user_b)

      [user_a_activity.mean, user_b_activity.mean].standard_deviation
    end
  end
end
