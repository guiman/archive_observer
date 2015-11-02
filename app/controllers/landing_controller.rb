class LandingController < ApplicationController
  def main
  end

  def user_profile
    redirect_to github_user_profile_path(params[:github_user][:login])
  end
end
