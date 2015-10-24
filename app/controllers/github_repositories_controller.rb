class GithubRepositoriesController < ApplicationController
  def top
    @top_repositories = ArchiveExtensions::TopActiveRepositories.for(count: params[:count])
  end

  def show
    @repository = GithubRepository.find(params[:repository])
  end
end
