require 'spec_helper'
describe CalendarPolicy do
  subject { described_class } # describe class uses the parent describe class: CalendarPolicy
  let(:user) { build :user, attrs }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
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
      it {expect(subject).not_to permit(user)}
    end
  end

  describe "can_manage?" do
    subject { CalendarPolicy.new(user, calendar) }
    let(:calendar) { build :calendar }
    let(:user) { build :user, attrs }

    context "user is a developer" do
      let(:attrs) {{affiliations: ["developer"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:calendar_sections)).to be_truthy }
      it { expect(subject.can_manage?(:seo)).to be_truthy }
    end

    context "user is an admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:calendar_sections)).to be_truthy }
      it { expect(subject.can_manage?(:seo)).to be_truthy }
    end

    context "user is any other affiliation" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_falsey }
      it { expect(subject.can_manage?(:permissions)).to be_falsey }
      it { expect(subject.can_manage?(:calendar_sections)).to be_falsey }
      it { expect(subject.can_manage?(:seo)).to be_falsey }
    end
  end
end
