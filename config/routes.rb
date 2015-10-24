Rails.application.routes.draw do
  get "/users/top/:count" => "github_users#top"
  get "/user/profile/:login" => "github_users#profile", as: "github_user_profile"

  get "/repositories/top/:count" => "github_repositories#top"
  get "/repository/:repository" => "github_repositories#show", as: "github_repository"
end
