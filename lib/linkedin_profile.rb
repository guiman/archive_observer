require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class LinkedinProfile
  attr_reader :login
  def initialize(login)
    @login = login
    @linkedin_link = nil
    @processed = false
  end

  def link
    return @linkedin_link if @processed

    begin
      # First we search their GH profile page
      github_page = Nokogiri::HTML(open("https://github.com/#{login}", allow_redirections: :safe, read_timeout: 1, open_timeout: 1))
      links = github_page.xpath('//a[@href]').map {|link| link["href"] }
      where_is_the_personal_site = links[9].include?("mailto") ? 10 : 9
      personal_site = links[where_is_the_personal_site]

      is_a_github_url = /(http|https):\/\/github.com.*/
      is_a_url =  /(http|https):\/\/.*/
      is_a_linkedin_url = personal_site.include?('linkedin')

      return if (personal_site =~ is_a_github_url)
      return unless (personal_site =~ is_a_url)

      if is_a_linkedin_url
        # For people putting their linkedin profile as personal site
        linkedin_link = personal_site
      else
        # And then we search in their personal site
        doc = Nokogiri::HTML(open(personal_site, allow_redirections: :safe, read_timeout: 1, open_timeout: 1))
        links = doc.xpath('//a[@href]').map {|link| link["href"] }
        linkedin_link = links.detect { |a| a.include?('linkedin') }
      end

      @processed = true
      @linkedin_link = linkedin_link
    rescue Exception => e
      Rails.logger.error("Found an error while processing linkedin profile for #{@login} -> #{e.to_s}")
    end
  end

  def verify_link
    return false unless link
    !(link =~ /(http|https):\/\/.*linkedin\.com/).nil?
  end
end
