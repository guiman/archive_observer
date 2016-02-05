module Chart
  class GithubUserCommitActivity
    MONTHS=(1..12).to_a

    attr_reader :year_to_display

    def initialize(github_login, year = Time.now.year)
      @github_login = github_login
      @year_to_display = year
    end

    # Row explanation:
    # [ "month_name", commits ]
    #
    # Output:
    # [
    #  [ "january", 10],
    #  ...
    #  [ "dicember", 2 ],
    # ]
    def monthly_language_activity
      months = Date::MONTHNAMES
      activity = ArchiveExtensions::UserActivity.commits_for(login: @github_login, year: @year_to_display)

      months.zip(activity)
    end

    def chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'Month')
      data_table.new_column('number', 'Commits')

      data_table.add_rows(monthly_language_activity)
      option = { height: 300 }
      GoogleVisualr::Interactive::LineChart.new(data_table, option)
    end
  end
end
