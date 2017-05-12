class AnnualCourseFetchWorker
  include Sidekiq::Worker

  attr_accessor :not_found, :updated, :errored
  def initialize
    @not_found = []
    @updated = []
    @errored = []
  end

  def perform
    logger.info 'Starting sync with CourseLeaf'
    update_existing_courses
    find_and_create_new_courses
    logger.info "Finishing sync with CourseLeaf. Failures: #{errored}"
  end

  def update_existing_courses
    Course.each do |course|
      # look up course
      course_key = key_with_leading_zeros(course.prefix, course.code)
      cl_course = CourseLeaf::Course.get(course_key)
      if cl_course
        update_or_create_course('Updated', course, cl_course)
      else
        logger.error "Couldn't find course: #{course_key}"
        not_found << course_key
      end
    end
  end

  def find_and_create_new_courses
    course_keys =
      Course.pluck(:prefix, :code).map{|c| key_with_leading_zeros(c[0], c[1])}
    # Make the call to the index page and strip all of the course links from the
    #  sub-pages
    cl_keys = CourseLeaf::Course.all_keys
    cl_keys.each do |key|
      # skip if the course has already been created.
      next if course_keys.include?(key)
      # visit the course links
      cl_course = CourseLeaf::Course.get(key)
      if cl_course
        # create a new course
        update_or_create_course('Created', Course.new, cl_course)
      else
        logger.error "Couldn't find course: #{key}"
        not_found << key
      end
    end
  rescue => e
    logger.error "somthing went wrong #{e}"
  end

  def update_or_create_course(action, course, cl_course)
    course.name = cl_course.title
    course.description = cl_course.description
    course.prerequisites = cl_course.prerequisites
    course.corequisites = cl_course.corequisites
    course.grade_mode = cl_course.grade_mode
    course.credits = cl_course.credits
    course.restrictions = cl_course.restrictions
    course.code = cl_course.course_key.match(/\d{1,3}/)[0].to_i
    course.prefix = cl_course.course_key.match(/[A-Z]{4}/)
    course.save
    logger.info "#{action}: #{course.course_key}" \
    "#{course.code < 100 ? ' from ' + cl_course.course_key : ''}"
    updated << course.course_key
  rescue => e
    logger.error "Course Invalid. course: #{cl_course.course_key}. #{e}"
    errored << course.course_key
  end

  # Ensures that the course code is 3 digits before lookup from course pallet
  # @param prefix [String]
  # @param code [Integer]
  # @return [String]
  def key_with_leading_zeros(prefix, code)
    "#{prefix} #{code.to_s.rjust(3, '0')}"
  end
end
