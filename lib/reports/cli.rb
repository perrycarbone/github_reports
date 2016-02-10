require 'dotenv'
Dotenv.load
require 'rubygems'
require 'bundler/setup'
require 'thor'
require 'reports/github_api_client'
require 'reports/table_printer'

module Reports

  class CLI < Thor

    desc "console", "Open an RB session with all dependencies loaded and API defined."
    def console
      require 'irb'
      ARGV.clear
      IRB.start
    end

    desc "user_info USERNAME", "Get info for a user"
    def user_info(username)
      puts "Getting user info for #{username}..."

      client = GitHubAPIClient.new(ENV['GITHUB_TOKEN'])
      user = client.user_info(username)

      puts "name: #{user["name"]}"
      puts "location: #{user["location"]}"
      puts "public repos: #{user["public_repos"]}"

    rescue Error => e
      puts "ERROR #{e.message}"
      exit 1
    end

    desc "public_repos_for_user USERNAME", "Get public repos for a user"
    def public_repos_for_user(username)
      puts "Getting public repos for #{username}..."

      client = GitHubAPIClient.new(ENV['GITHUB_TOKEN'])
      repos = client.public_repos_for_user(username)

      repos.each do |repo|
        puts "#{repo["name"]} - #{repo["url"]}"
      end
    end

    private

    def client
      @client ||= GitHubAPIClient.new
    end

  end

end
