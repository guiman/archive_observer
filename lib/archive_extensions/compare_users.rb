require 'descriptive_statistics'

module ArchiveExtensions
  class CompareUsers
    COMPARED_LANGUAGES = 4

    def self.calculate_language_similarity(user_a:, user_b:)
      user_a_languages = ArchiveExtensions::Languages.for(user_a).
        first(COMPARED_LANGUAGES).map {|x| x.fetch("language").name }
      user_b_languages = ArchiveExtensions::Languages.for(user_b).
        first(COMPARED_LANGUAGES).map {|x| x.fetch("language").name }

      whole_list_of_languages = (user_a_languages | user_b_languages).count
      language_intersection = (user_a_languages & user_b_languages).count

      language_intersection.to_f / whole_list_of_languages.to_f * 100.to_f
    end

    def self.calculate_activity_difference(user_a:, user_b:, year: Time.now.year)
      user_a_activity = ArchiveExtensions::UserActivity.for(login: user_a, year: year)
      user_b_activity = ArchiveExtensions::UserActivity.for(login: user_b, year: year)

      abs_mean_difference = (user_a_activity.mean - user_b_activity.mean).abs
      max_mean = [user_a_activity.mean, user_b_activity.mean].max
      mean_difference_percentage = abs_mean_difference / max_mean * 100

      abs_sd_difference = (user_a_activity.standard_deviation - user_b_activity.standard_deviation).abs
      max_sd = [user_a_activity.standard_deviation, user_b_activity.standard_deviation].max
      sd_difference_percentage = abs_sd_difference / max_sd * 100

      if mean_difference_percentage == 0.0
        sd_difference_percentage
      else
        mean_difference_percentage
      end
    end
  end
end
