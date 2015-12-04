class Api::UsersController < ApplicationController
  respond_to :json

  def user
    @user = GithubUser.find_by_login(params[:handle])

    render :missing, :status => 422 unless @user
  end
end
