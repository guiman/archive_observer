class GithubUsersController < ApplicationController
  def profile
    @user = GithubUser.find_by_login(params[:login])
    @year = (params[:year] || Time.now.year).to_i
    @alternative_year = ([Time.now.year - 1, Time.now.year] - [@year]).first

    if @user
      render "profile"
    else
      render "missing_profile"
    end
  end
end
