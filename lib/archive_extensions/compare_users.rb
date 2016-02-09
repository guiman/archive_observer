require 'descriptive_statistics'

module ArchiveExtensions
  class CompareUsers
    COMPARED_LANGUAGES = 4

    def self.calculate_language_similarity(user_a:, user_b:)
      user_a_id = GithubUser.find_by(login: user_a).id
      user_b_id = GithubUser.find_by(login: user_b).id

      user_ids = [user_a_id, user_b_id].join(',')

      results = Language.connection.select_all("
          SELECT github_pull_requests.github_user_id as user_id, languages.name as language_name, count(github_pull_requests.id) as prs
          FROM languages
          INNER JOIN github_repositories on github_repositories.language_id = languages.id
          INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
          WHERE github_pull_requests.github_user_id in (#{user_ids}) AND github_pull_requests.action = 'opened'
          GROUP BY github_pull_requests.github_user_id, languages.name
          ORDER BY prs desc")

      data = results.inject([]) do |acc, result|
        pr_count = result.fetch("prs")
        acc << {
          "user_id" => result.fetch("user_id").to_i,
          "language" => result.fetch("language_name"),
          "prs" => pr_count.to_i
        }
      end

      user_a_languages = data.map do |some_data|
        some_data.fetch("language") if some_data.fetch("user_id") == user_a_id
      end.compact.first(COMPARED_LANGUAGES)

      user_b_languages = data.map do |some_data|
        some_data.fetch("language") if some_data.fetch("user_id") == user_b_id
      end.compact.first(COMPARED_LANGUAGES)

      whole_list_of_languages = (user_a_languages | user_b_languages).count
      language_intersection = (user_a_languages & user_b_languages).count

      language_intersection.to_f / whole_list_of_languages.to_f * 100.to_f
    end

    def self.calculate_activity_difference(user_a:, user_b:, year: Time.now.year)
      user_a_id = GithubUser.find_by(login: user_a).id
      user_b_id = GithubUser.find_by(login: user_b).id

      user_ids = [user_a_id, user_b_id].join(',')

      results = GithubUser.connection.select_all("
        SELECT github_pull_requests.github_user_id as user_id, count(github_pull_requests.id) as prs, Extract(month from github_pull_requests.event_timestamp) as month
        FROM github_users
        INNER JOIN github_pull_requests on github_pull_requests.github_user_id = github_users.id
        WHERE github_pull_requests.github_user_id in (#{user_ids}) AND github_pull_requests.action = 'opened' AND Extract(year from github_pull_requests.event_timestamp) = '#{year}'
        GROUP BY github_pull_requests.github_user_id, month
        ORDER BY month asc")

      data = results.inject([]) do |acc, result|
        pr_count = result.fetch("prs")
        acc << {
          "user_id" => result.fetch("user_id").to_i,
          "month" => result.fetch("month").to_i,
          "prs" => pr_count.to_i
        }
      end

      user_a_activity = (1..12).to_a.map do |month|
        value = data.detect { |user_data| user_data.fetch("month") == month && user_data.fetch("user_id") == user_a_id }
        value ? value.fetch("prs").to_i : 0
      end

      user_b_activity = (1..12).to_a.map do |month|
        value = data.detect { |user_data| user_data.fetch("month") == month && user_data.fetch("user_id") == user_b_id }
        value ? value.fetch("prs").to_i : 0
      end

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
