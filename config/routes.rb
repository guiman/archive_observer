Rails.application.routes.draw do
  root "landing#main"
  get "/find_user_profile" => "landing#user_profile"

  get "/users/top/:count" => "github_users#top", as: "top_users"
  get "/user/profile/:login" => "github_users#profile", as: "github_user_profile"

  get "/repositories/top/:count" => "github_repositories#top", as: "top_repositories"
  get "/repository/:repository" => "github_repositories#show", as: "github_repository"
end
