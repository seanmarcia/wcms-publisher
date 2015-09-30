require 'spec_helper'
describe PageEditionPolicy do
  subject { described_class } # describe class uses the parent describe class: PageEditionPolicy
  let(:user) { build :user, attrs }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
    context "user is a developer" do
      let(:attrs) {{affiliations: ["developer"]}}
      xit { expect(subject).to permit(user) }
    end

    context "user is an admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      xit { expect(subject).to permit(user) }
    end

    context "user is both an admin and a developer" do
      let(:attrs) {{affiliations: ["admin", "developer"]} }
      xit { expect(subject).to permit(user) }
    end

    context "user is any other affiliation" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      xit {expect(subject).not_to permit(user)}
    end
  end

  describe "can_manage?" do
    subject { PageEditionPolicy.new(user, page_edition) }
    let(:page_edition) { build :page_edition }
    let(:user) { build :user, attrs }

    context "user is a developer" do
      let(:attrs) {{affiliations: ["developer"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:presentation_data)).to be_truthy }
      it { expect(subject.can_manage?(:attachments)).to be_truthy }
      it { expect(subject.can_manage?(:audience_collections)).to be_truthy }
      it { expect(subject.can_manage?(:seo)).to be_truthy }
    end

    context "user is an admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:presentation_data)).to be_truthy }
      it { expect(subject.can_manage?(:attachments)).to be_truthy }
      it { expect(subject.can_manage?(:audience_collections)).to be_truthy }
      it { expect(subject.can_manage?(:seo)).to be_truthy }
    end

    context "user is any other affiliation" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:activity_logs)).to be_falsey }
      it { expect(subject.can_manage?(:permissions)).to be_falsey }
      it { expect(subject.can_manage?(:presentation_data)).to be_falsey }
      it { expect(subject.can_manage?(:attachments)).to be_falsey }
      it { expect(subject.can_manage?(:audience_collections)).to be_falsey }
      it { expect(subject.can_manage?(:seo)).to be_falsey }
    end
  end
end
