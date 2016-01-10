class ArchiveUserLocation
  def self.update(github_user, client)
    location = client.user(github_user.login).location
    location = nil if location && location.empty?
    github_user.update(location: location, reachable: true)
  rescue Octokit::NotFound
    github_user.update(reachable: false)
  end
end
