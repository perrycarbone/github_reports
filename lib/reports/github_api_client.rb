require 'faraday'
require 'json'
require 'logger'

module Reports

  class Error < StandardError; end
  class NonexistantUser < Error; end
  class RequestFailure < Error; end
  class AuthenticationFailure < Error; end

  User = Struct.new(:name, :location, :public_repos)

  class GitHubAPIClient
    VALID_STATUS_CODES = [200, 302, 403, 422]

    def initialize(token)
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc { |severity, datetime, program, message| message + "\n" }
      @token = token
    end

    def user_info(username)
      headers = {"Authorization" => 'token #{@token}'}
      url = "https://api.github.com/users/#{username}"

      start_time = Time.now
      response = Faraday.get url
      duration = Time.now - start_time

      @logger.debug "-> %s %s %d (%.3f s)" % [url, 'GET', response.status, duration]

      if response.status == 404
        raise NonexistantUser, "'#{username}' does not exist."
      elsif !VALID_STATUS_CODES.include?(response.status)
        raise RequestFailure, JSON.parse(response.body)["message"]
      elsif response.status == 401
        raise AuthenticationFailure, "Authentication failed.  Please set the 'GITHUB_TOKEN' env variable to a valid github access token."
      end

      data = JSON.parse(response.body)
      User.new(data["name"], data["location"], data["public_repos"])
    end
  end
end
