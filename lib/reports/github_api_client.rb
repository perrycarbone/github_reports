require 'faraday'
require 'json'

module Reports

  User = Struct.new(:name, :location, :public_repos)

  class GitHubAPIClient
    def user_info
      response = Faraday.get("https://api.github.com/users/perrycarbone")
      data = JSON.parse(response.body)
      User.new(data["name"], data["location"], data["public_repos"])
    end
  end
end
