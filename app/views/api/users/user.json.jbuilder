json.user do
  json.handle @user.login
  json.stats do
    json.languages ArchiveExtensions::Languages.for(@user.login) do |language|
      json.name language.fetch("language").name
      json.prs language.fetch("prs")
    end
  end
end
