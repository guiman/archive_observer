class GithubUsersController < ApplicationController
  def profile
    @user = GithubUser.find_by_login(params[:login])
  end
end
