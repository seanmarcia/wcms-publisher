require 'spec_helper'

describe AnnualCourseFetchWorker, type: :unit do
  let(:worker) { AnnualCourseFetchWorker.new }
  let(:raw_xml) { 'spec/fixtures/course_leaf_course.xml' }
  let(:nokogiri_response) { Nokogiri::HTML(open(raw_xml)) }
  let(:course_leaf_course) { CourseLeaf::Course.new(nokogiri_response) }

  describe 'update_existing_courses' do
    subject { worker.update_existing_courses }

    context 'without existing courses' do
      it 'should update the course' do
        CourseLeaf::Course.stub(:get).and_return(course_leaf_course)
        expect(subject.count).to eq 0
      end
    end

    context 'with course that exists in the db and CourseLeaf' do
      let(:course) { create :course, prefix: 'BUSN', code: 5, name: 'things' }

      it 'should update the course' do
        CourseLeaf::Course.stub(:get).and_return(course_leaf_course)
        expect(course.name).to eq 'things'
        expect(subject.count).to eq 1
        expect(subject.first).to eq course
        course.reload
        expect(course.name).to eq 'Economic Principles'
      end
    end

    context 'with course that exists in the db but not in CourseLeaf' do
      let(:faux_course) { create :course, name: 'things2' }

      it 'should not update the course' do
        CourseLeaf::Course.stub(:get).and_return(nil)
        expect(faux_course.name).to eq 'things2'
        expect(subject.count).to eq 1
        expect(subject.first).to eq faux_course
        faux_course.reload
        expect(faux_course.name).to eq 'things2'
      end
    end
  end

  describe 'find_and_create_new_courses' do
    subject { worker.find_and_create_new_courses }

    let(:course_keys) { ['BUSN 005'] }

    context 'with course that exists in the db and in CourseLeaf' do
      let(:course) { create :course, prefix: 'BUSN', code: 5, name: 'things' }

      it 'skips the course' do
        CourseLeaf::Course.stub(:all_keys).and_return(course_keys)
        expect(course.name).to eq 'things'
        expect(Course.count).to eq 1
        expect(subject).to eq course_keys
      end
    end

    context 'with a new course from CourseLeaf' do
      it 'skips the course' do
        CourseLeaf::Course.stub(:all_keys).and_return(course_keys)
        CourseLeaf::Course.stub(:get).and_return(course_leaf_course)
        expect(Course.count).to eq 0
        expect(subject).to eq course_keys
        expect(Course.count).to eq 1
      end
    end
  end

  describe 'update_or_create_course' do
    let(:action) { '' }
    let(:course) { nil }
    subject {
      worker.update_or_create_course(action, course, course_leaf_course)
    }

    context 'on create' do
      let(:action) { 'Created' }
      let(:course) { Course.new }

      it 'creates a new course' do
        expect(Course.count).to eq 0
        expect(subject).to eq ['BUSN 5']
        expect(Course.count).to eq 1
        expect(Course.first.course_key).to eq 'BUSN 5'
      end
    end

    context 'on update' do
      let(:action) { 'Updated' }
      let!(:course) { create :course }

      it 'updates a preexisting course' do
        expect(Course.count).to eq 1
        expect(subject).to eq ['BUSN 5']
        expect(Course.count).to eq 1
        expect(Course.first.course_key).to eq 'BUSN 5'
      end
    end
  end

  describe 'key_with_leading_zeros' do
    let(:prefix) { 'BUSN' }
    let(:code) { nil }

    subject { worker.key_with_leading_zeros(prefix, code) }

    context 'with a single digit code' do
      let(:code) { '5' }
      it 'returns BUSN 005' do
        expect(subject).to eq 'BUSN 005'
      end
    end

    context 'with a double digit code' do
      let(:code) { '50' }
      it 'returns BUSN 050' do
        expect(subject).to eq 'BUSN 050'
      end
    end

    context 'with a tripple digit code' do
      let(:code) { '500' }
      it 'returns BUSN 500' do
        expect(subject).to eq 'BUSN 500'
      end
    end

    context 'with a quadruple digit code' do
      let(:code) { '5000' }
      it 'returns BUSN 5000' do
        expect(subject).to eq 'BUSN 5000'
      end
    end
  end
end
