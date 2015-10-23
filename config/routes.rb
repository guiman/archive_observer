Rails.application.routes.draw do
  get "/profile/:login" => "github_users#profile"
  get "/repositories/top/:count" => "github_repositories#top"
end
