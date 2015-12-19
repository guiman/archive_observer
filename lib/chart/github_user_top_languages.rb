module Chart
  class GithubUserTopLanguages
    def initialize(github_login)
      @github_login = github_login
    end

    def languages
      ArchiveExtensions::Languages.for(@github_login)
    end

    # Row explanation:
    # [ "language", prs ]
    #
    # Output:
    # [
    #  ["Ruby", 3],
    #  ...
    #  ["CSS", 1]
    # ]
    def language_prs
      languages.map do |language|
        [language.fetch("language").name, language.fetch("prs")]
      end
    end

    def chart
      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'Language')
      data_table.new_column("number", 'PRs')
      data_table.add_rows(language_prs)
      option = { height: 300 }
      GoogleVisualr::Interactive::PieChart.new(data_table, option)
    end
  end
end
