require 'spec_helper'

describe CourseLeaf::Course do
  let(:course_key) { 'BUSN 005' }
  let(:raw_xml) { 'spec/fixtures/course_leaf_course_with_prereqs.xml' }
  let(:nokogiri_response) { Nokogiri::HTML(open(raw_xml)) }
  let(:course_leaf_course) { CourseLeaf::Course.new(nokogiri_response) }

  describe 'get BUSN 005' do
    context 'course_key' do
      subject { course_leaf_course.course_key }
      it { should eq course_key }
    end

    context 'title' do
      subject { course_leaf_course.title }
      it { should eq 'Economic Principles' }
    end

    context 'credits' do
      subject { course_leaf_course.credits }
      it { should eq '3' }
    end

    context 'description' do
      subject { course_leaf_course.description }
      it {
        should eq 'Micro and macro economic theory with an emphasis on the ' \
        'application of this theory to current economic issues, including ' \
        'the study of those who developed the theory and their predecessors. ' \
        'Issues involving trade and finance among nations and their ' \
        'comparative economic systems will also be examined. Grade Mode: A.'
      }
    end

    context 'prerequisites' do
      subject { course_leaf_course.prerequisites }
      it {
        should eq 'ISAN 571'
      }
    end

    context 'grade_mode' do
      subject { course_leaf_course.grade_mode }
      it { should eq 'A' }
    end

    context 'restrictions' do
      subject { course_leaf_course.restrictions }
      it {
        should eq 'Must not be Business Administration (BUSN); and  must be ' \
        'Undergraduate Level.'
      }
    end
  end

  describe 'get BUSN 005 - no prerequisites' do
    let(:course_key) { 'BUSN 005' }
    let(:raw_xml) { 'spec/fixtures/course_leaf_course.xml' }

    context 'course_key' do
      subject { course_leaf_course.course_key }
      it { should eq course_key }
    end

    context 'title' do
      subject { course_leaf_course.title }
      it { should eq 'Economic Principles' }
    end

    context 'credits' do
      subject { course_leaf_course.credits }
      it { should eq '3' }
    end

    context 'description' do
      subject { course_leaf_course.description }
      it {
        should eq 'Micro and macro economic theory with an emphasis on the ' \
        'application of this theory to current economic issues, including ' \
        'the study of those who developed the theory and their predecessors. ' \
        'Issues involving trade and finance among nations and their ' \
        'comparative economic systems will also be examined. Grade Mode: A.'
      }
    end

    context 'prerequisites' do
      subject { course_leaf_course.prerequisites }
      it { should be nil }
    end

    context 'grade_mode' do
      subject { course_leaf_course.grade_mode }
      it { should eq 'A' }
    end

    context 'restrictions' do
      subject { course_leaf_course.restrictions }
      it {
        should eq 'Must not be Business Administration (BUSN); and  must be ' \
        'Undergraduate Level.'
      }
    end
  end

  describe 'scrape_programs_from_index' do
    let(:all_programs) {
      JSON.parse(File.read('spec/fixtures/all_programs.json'))
    }
    let!(:course_leaf_index_xml) {
      Nokogiri::HTML(open('spec/fixtures/course_leaf_index.xml'))
    }

    subject { CourseLeaf::Course.scrape_programs_from_index }

    it 'gets all of the course programs from the index page' do
      Nokogiri.stub(:HTML).and_return(course_leaf_index_xml)
      expect(subject).to eq all_programs
    end
  end

  describe 'scrape_keys_from_programs' do
    let(:program_keys) {
      JSON.parse(File.read('spec/fixtures/program_keys.json'))
    }
    let!(:course_leaf_program_xml) {
      Nokogiri::HTML(open('spec/fixtures/course_leaf_program.xml'))
    }
    let(:link) { '/courses/busn/' }
    let(:keys) { [] }

    subject { CourseLeaf::Course.scrape_keys_from_programs(link, keys) }

    it 'gets all of the keys from a program page' do
      Nokogiri.stub(:HTML).and_return(course_leaf_program_xml)
      expect(subject).to eq program_keys
    end
  end
end
