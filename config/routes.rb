Rails.application.routes.draw do
  get "/profile/:login" => "github_users#profile"
end
