module Chart
  class GithubUserActivity
    MONTHS=(1..12).to_a

    def initialize(github_login)
      @github_login = github_login
    end

    def languages
      ArchiveExtensions::Languages.for(@github_login)
    end

    # Row explanation:
    # [ "month_name", ruby_prs, js_prs, pythong_prs ]
    #
    # Output:
    # [
    #  [ "january", 1, 2, 3 ],
    #  ...
    #  [ "dicember", 6, 0, 2 ],
    # ]
    def monthly_language_activity
      memoized_language_breakdowns = all_languages_monthly_activity

      MONTHS.map do |month|
        res = [Date::MONTHNAMES[month]]
        memoized_language_breakdowns.each do |lang, breakdown|
          value = breakdown.detect { |b| b.fetch("month") == month }
          prs = value ? value.fetch("prs") : 0
          res << prs
        end
        res
      end
    end

    def chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'Month')
      languages.each do |lang|
        data_table.new_column("number", lang.fetch("language").name)
      end
      data_table.add_rows(monthly_language_activity)
      option = { height: 300 }
      GoogleVisualr::Interactive::LineChart.new(data_table, option)
    end

    private

    def all_languages_monthly_activity
      languages.inject({}) do |acc, language|
        language_name = language.fetch("language").name
        breakdown = ArchiveExtensions::LanguageBreakdown.for(login: @github_login, language: language_name)
        acc[language_name] = breakdown
        acc
      end
    end
  end
end
