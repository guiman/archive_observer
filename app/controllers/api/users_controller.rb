class Api::UsersController < ApplicationController
  respond_to :json

  def user
    @user = GithubUser.find_by_login(params[:handle])
    year_to_display = params[:year].present? ? params[:year].to_i : Time.now.year
    @chart_data = Chart::GithubUserActivity.new(params[:handle], year_to_display)

    render :missing, :status => 422 unless @user
  end
end
