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

      return if (personal_site =~ is_a_github_url)
      return unless (personal_site =~ is_a_url)

      # And then we search in their personal site
      doc = Nokogiri::HTML(open(personal_site, allow_redirections: :safe, read_timeout: 1, open_timeout: 1))
      links = doc.xpath('//a[@href]').map {|link| link["href"] }
      linkedin_link = links.detect { |a| a.include?('linkedin') }

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

  def headline
    return "" unless link

    begin
      @page ||= Nokogiri::HTML(open(link, allow_redirections: :safe))
      @page.css('div#headline').text
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Found an error while processing linkedin profile for #{@login} -> #{e.to_s}")
      return ""
    end
  end

  def skills
    return [] unless link

    begin
      @page ||= Nokogiri::HTML(open(link, allow_redirections: :safe))
      @page.css('span.endorse-item-name').map { |e| e.text }
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Found an error while processing linkedin profile for #{@login} -> #{e.to_s}")
      return []
    end
  end

  def education
    return {} unless link

    begin
      @page = Nokogiri::HTML(open(link, allow_redirections: :safe))
      education_element = @page.css('div#background-education')
      return {} if education_element.empty?

      university = education_element.css('div.education.first header h4').text
      degree = education_element.css('div.education.first header h5 span').map(&:text).join('')
      { university: university, degree: degree }
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Found an error while processing linkedin profile for #{@login} -> #{e.to_s}")
      return {}
    end
  end

  def experience
    return [] unless link

    begin
      @page ||= Nokogiri::HTML(open(link, allow_redirections: :safe))
      experience_element = @page.css('div#background-experience')
      experience = []

      experience_element.css('div.current-position').each do |current_position_element|
        experience << {
          position: current_position_element.css('header h4').text,
          company: (current_position_element.css('header h5 a').text.empty?) ? current_position_element.css('header span').text : current_position_element.css('header h5 a').text,
          period: experience_element.css('div.current-position span.experience-date-locale').text,
          current: true
        }
      end

      experience_element.css('div.past-position').each do |position_element|
        experience << {
          position: position_element.css('header h4').text,
          company: (position_element.css('header h5 a').text.empty?) ? position_element.css('header span').text : position_element.css('header h5 a').text,
          period: position_element.css('span.experience-date-locale').text,
          current: false
        }
      end

      experience
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Found an error while processing linkedin profile for #{@login} -> #{e.to_s}")
      return []
    end
  end
end
