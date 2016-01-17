json.user do
  json.handle @user.login
  json.stats do
    json.year_to_display @chart_data.year_to_display
    json.languages @chart_data.languages do |language|
      json.name language.fetch("language").name
      json.prs language.fetch("prs")
    end
    json.activity @chart_data.monthly_language_activity
  end
end
