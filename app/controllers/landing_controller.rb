class LandingController < ApplicationController
  def main
  end

  def user_profile
    redirect_to github_user_profile_path(params[:github_user][:login])
  end

  def monthly_selection
    # ArchiveExtensions::MonthlySelection.candidates
    # Calculate all developers monthly PR count for the last year
    #
    # Someone is interesting if in the period defined, they have an
    # PR count in a certain range, for the languages specified.
    #
    # User Case:
    # I want to find people between 2-5 PRs in a manth that point to
    # Javascript, Ruby or CSS.
    languages = Language.where(name: ["JavaScript", "Ruby", "CSS"])
    current_month = Time.now.month
    prs_range = (1..10)

    @users = GithubUser.where("reachable = ? and location is not null", true).order("RANDOM()").limit(500).select do |user|
      lang_data = languages.inject({}) do |acc, language|
        language_name = language.name
        breakdown = ArchiveExtensions::LanguageBreakdown.for(login: user.login, language: language_name)

        acc[language_name] = breakdown.detect(Proc.new { Hash.new }) do |data|
          data.fetch("month") == current_month
        end.fetch("prs", 0)

        acc
      end

      languages.any? { |lang| prs_range.include? lang_data[lang.name] }
    end
  end
end
