class GithubUsersController < ApplicationController
  def top
    @top_developers = ArchiveExtensions::TopActiveDevelopers.for(count: params[:count].to_i)
  end

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
