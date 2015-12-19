module ActivityHelper
  def languages_for(github_login)
    ArchiveExtensions::Languages.for(github_login)
  end
end
