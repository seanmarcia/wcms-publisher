module CourseLeaf
  # Retrieves course information from CourseLeaf's course catalog API
  #
  # Class for interfacing with the CourseLeaf course catalog API
  # The API is unauthenticated, so these are just
  # simple HTTP GET requests.
  #
  class Course
    require 'nokogiri'

    attr_reader :course_key, :title_html, :title, :description_html,
                :description, :full_description, :credits, :corequisites,
                :prerequisites, :grade_mode, :restrictions

    BASE_URL =
      "#{Settings.course_leaf.url}/ribbit/?page=getcourse.rjs&code=".freeze
    INDEX_URL = "#{Settings.course_leaf.url}/courses/index.xml".freeze
    COURSE_SELECTOR = '//courseinfo/course'.freeze
    COURSE_TITLE_SELECTOR = '.courseblocktitle'.freeze
    COURSE_DESCRIPTION_SELECTOR = '.courseblockdesc'.freeze

    # use self.get() to initialize
    def initialize(api_response)
      node = api_response.at_xpath(COURSE_SELECTOR)
      @course_key = node[:code] # .at_css('course')[:code]
      @title_html = node.css(COURSE_TITLE_SELECTOR).inner_html
      @credits = node.css('span').text.gsub(/Credit(s?) /, '')
      @description_html = node.css(COURSE_DESCRIPTION_SELECTOR).inner_html
    end

    # @return [String]
    def title
      @title ||= title_html.match(/-\s*(.*?)(?=<span)/)[1].strip
    end

    # @return [String]
    def description
      return unless (match = description_html.match(/(.*?)<br>/))
      text_only(match[1])
    end

    # @return [String]
    def prerequisites
      match = description_html.match(/(.*)Prerequisites:(.*?)<br>/)
      return unless match
      text_only(match[2]).gsub(/.$/, '')
    end

    # @return [String]
    def corequisites
      match = description_html.match(/(.*)Corequisites:(.*?)<br>/)
      return unless match
      text_only(match[2]).gsub(/.$/, '')
    end

    # @return [String]
    def grade_mode
      match = description_html.match(/(.*)<strong>Grade Mode:(.*?)<br>/)
      return unless match
      text_only(match[2]).gsub(/.$/, '')
    end

    # @return [String]
    def restrictions
      match = description_html.match(/(.*)<strong>Restrictions:(.*?)<br>/)
      return unless match
      text_only(match[2])
    end

    # Queries the CourseLeaf API for a course
    # @param course_key [String] Course Key for API Lookup
    # @return [CourseLeaf::Course,nil]
    def self.get(course_key)
      raise ArgumentError 'Missing required course key' if course_key.blank?
      unless course_key.is_a? String
        raise ArgumentError 'Parameter must be a String'
      end
      request_url = URI.escape(BASE_URL + course_key)
      response = Nokogiri::HTML(open(request_url))
      new(response) if response.at_xpath(COURSE_SELECTOR)
    rescue => e
      raise "Error connecting to url='#{request_url}': #{e}"
    end

    # Queries the CourseLeaf API for all course_keys
    # @return [CourseLeaf::Courses,nil]
    def self.all_keys
      keys = []
      links = scrape_programs_from_index
      links.each { |link| scrape_keys_from_programs(link, keys) }
      return keys
    rescue => e
      raise "Error connecting to url='#{request_url}': #{e}"
    end

    # Strips out HTML, non-breaking space (ascii 160), and trailing spaces
    # @param html [String]
    # @return [String]
    def self.text_only(html)
      Nokogiri::HTML.parse(html).text.gsub(/\A\p{Space}+|\p{Space}+\z/, '')
                    .strip
    end

    # Scrapes program relative links from the course leaf index page.
    # @return [Array]
    def self.scrape_programs_from_index
      request_url = URI.escape(INDEX_URL)
      response = Nokogiri::HTML(open(request_url)) # maybe use text_only here
      response.to_s.scan(%r{\/courses\/[a-z]{4}\/})
    end

    # Scrapes course keys from program pages and appends them to the keys array
    # @param link [String] Relative program link from index page
    # @param keys [Array]
    # @return [String]
    def self.scrape_keys_from_programs(link, keys)
      request_url = URI.escape("#{Settings.course_leaf.url}#{link}index.xml")
      response = Nokogiri::HTML(open(request_url)) # maybe use text_only here
      keys <<
        text_only(response.to_s.gsub('&nbsp;', ' ')).scan(/[A-Z]{4}\s+\d{1,3}/)
      keys.flatten!.uniq! if keys
    end

    private

    # Strips out HTML, non-breaking space (ascii 160), and trailing spaces
    # @param html [String]
    # @return [String]
    def text_only(html)
      Nokogiri::HTML.parse(html).text.gsub(/\A\p{Space}+|\p{Space}+\z/, '')
                    .strip
    end
  end
end
