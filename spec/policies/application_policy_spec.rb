require 'spec_helper'
describe ApplicationPolicy do
  subject { described_class } # describe class uses the parent describe class: ApplicationPolicy

  permissions :index?, :create?, :new?, :update?, :edit?, :destroy? do
    context "user with any affiliations" do
      let(:user) { build :user, {affiliations: ["student", "admin", "developer", "faculty", "staff", "alumni"]}}
      it { expect(subject).not_to permit(user) }
    end
  end

  permissions :show? do
    context 'scope by user and record by id' do
      xit {} # this should be finished.
    end
  end
end
