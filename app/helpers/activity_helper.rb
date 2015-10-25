module ActivityHelper
  def languages_for(github_login)
    languages = ArchiveExtensions::Languages.for(github_login)

    languages.map do |lang|
      lang["name"] = "Unknown" if lang.fetch("name").nil?
      lang
    end
  end

  def chart_languages_for(github_login)
    languages = languages_for(github_login)

    languages.map { |lang| lang.fetch("name") }.uniq
  end

  def chart_data_for(github_login)
    languages_breakdown_data = ArchiveExtensions::Languages.for(github_login).inject({}) do |acc, language|
      breakdown = ArchiveExtensions::LanguageBreakdown.for(login: github_login, language: language.fetch("name"))
      acc[language.fetch("name")] = breakdown
      acc
    end

    (1..12).to_a.map do |month|
      res = [month]
      languages_breakdown_data.each do |lang, breakdown|
        value = breakdown.detect { |b| b.fetch("month") == month }
        prs = value ? value.fetch("prs") : 0
        res << prs
      end
      res
    end
  end
end
