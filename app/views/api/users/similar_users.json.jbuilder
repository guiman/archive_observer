json.user do
  json.handle @user.login
  json.year_to_display @year
  json.similar @similar_users
end
