class GithubRepositoriesController < ApplicationController
  def top
    @repositories = ArchiveExtensions::TopActiveRepositories.for(count: params[:count])
  end
end
