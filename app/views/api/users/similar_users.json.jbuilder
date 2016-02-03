json.user do
  json.handle @user.login
  json.year_to_display @year
  json.language_threshold @language_threshold
  json.activity_threshold @activity_threshold
  json.similar @similar_users
end
