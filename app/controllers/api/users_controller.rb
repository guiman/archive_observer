class Api::UsersController < ApplicationController
  respond_to :json

  def user
    @user = find_user
    @chart_data = Chart::GithubUserActivity.new(params[:handle], year_to_display)

    render :missing, :status => 422 unless @user
  end

  def similar_users
    @user = find_user
    @year = year_to_display
    language_threshold = params[:language_threshold].present? ? params[:language_threshold].to_f : 40.0
    @similar_users = ArchiveExtensions::SimilarUsers.calculate(login: @user.login,
      year: @year, language_threshold: language_threshold).map { |user| user.login }

    render :missing, :status => 422 unless @user
  end

  private

  def find_user
    GithubUser.find_by_login(params[:handle])
  end

  def year_to_display
    params[:year].present? ? params[:year].to_i : Time.now.year
  end
end
