require 'spec_helper'
describe ApplicationPolicy do
  subject { described_class } # describe class uses the parent describe class: ApplicationPolicy

  permissions :index?, :create?, :new?, :update?, :edit?, :destroy? do
    context "user with any affiliations" do
      let(:user) { build :user, affiliations: ["student", "admin", "developer", "faculty", "staff", "alumni"]}
      it { expect(subject).not_to permit(user) }
    end
  end

  describe :show? do
    subject { ApplicationPolicy.new(user, page_edition) }
    context 'if the record does not exist' do
      let(:user) { build :user }
      let(:page_edition) { build :page_edition }
      it { expect(subject).not_to sanction(:show)}
    end

    context 'if the record exists and is accessable by the user' do
      let(:user) { build :user, affiliations: ["admin"] }
      let(:page_edition) { create :page_edition }
      it { expect(subject).to sanction(:show)}
    end

    context 'if the record exists but is not accessable by the user' do
      let(:user) { build :user, affiliations: ["student"] }
      let(:page_edition) { create :page_edition }
      it { expect(subject).not_to sanction(:show)}
    end
  end
end
