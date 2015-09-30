require 'spec_helper'
describe AttachmentPolicy do
  subject { described_class } # describe class uses the parent describe class: AttachmentPolicy
  let(:user) { build :user, attrs }

  permissions :update?, :edit? do
    context "user with any affiliations" do
      let(:attrs) {{affiliations: ["student", "admin", "developer", "faculty", "staff", "alumni"]}}
      it { expect(subject).not_to permit(user) }
    end
  end

  permissions :index?, :create?, :new?, :destroy? do
    context "user is a developer" do
      let(:attrs) {{affiliations: ["developer"]}}
      it { expect(subject).to permit(user) }
    end

    context "user is an admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      it { expect(subject).to permit(user) }
    end

    context "user is both an admin and a developer" do
      let(:attrs) {{affiliations: ["admin", "developer"]} }
      it { expect(subject).to permit(user) }
    end

    context "user is any other affiliation" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      it { expect(subject).not_to permit(user) }
    end
  end
end
