class GithubRepositoriesController < ApplicationController
  def top
    @language = Language.where("name ILIKE ?", params[:language]).first
    @top_repositories = ArchiveExtensions::TopActiveRepositories.for(count: params[:count].to_i, language: @language)
  end

  def show
    @repository = GithubRepository.find(params[:repository])
  end
end
