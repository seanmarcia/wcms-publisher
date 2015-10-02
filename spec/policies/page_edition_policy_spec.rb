require 'spec_helper'
describe PageEditionPolicy do
  subject { PageEditionPolicy.new(user, page_edition) } # describe class uses the parent describe class: PageEditionPolicy
  let(:user) { create :user, affiliations: affiliations, entitlements: entitlements }
  let(:affiliations) {[]}
  let(:entitlements) {[]}
  let(:page_edition) { create :page_edition, site: site, permissions: page_permissions }
  let(:page_permissions) {[]}
  let(:site) { create :site, permissions: site_permissions }
  let(:site_permissions) {[]}

  describe 'role and set permission based permissions' do
    context "user is has no roles or permissions" do
      let(:affiliations) {["student", "faculty", "staff", "alumni"]}
      it { expect(subject).not_to sanction(:create)}
      it { expect(subject).not_to sanction(:new)}
      it { expect(subject).not_to sanction(:index)}
      it { expect(subject).not_to sanction(:show)}
      it { expect(subject).not_to sanction(:edit)}
      it { expect(subject).not_to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end

    context "user is an admin" do
      let(:affiliations) {["admin"]}
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).to sanction(:destroy)}
    end

    context "user is a developer" do
      let(:affiliations) {["developer"]}
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).to sanction(:destroy)}
    end

    context "user is a page edition admin" do
      let(:entitlements) { ["urn:biola:apps:wcms:page_edition_admin"] }
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end

    context "user is a page editor" do
      let(:page_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :edit)] }
      it { expect(subject).not_to sanction(:create)}
      it { expect(subject).not_to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end

    context "user is a site page editor" do
      let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :page_edition_editor)] }
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end

    context "user is a particular page editor" do
      let(:page_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :edit)] }
      it { expect(subject).not_to sanction(:create)}
      it { expect(subject).not_to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end

    context "user is a particular page editor" do
      let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :page_edition_publisher)] }
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end
  end

  describe "can_manage?" do
    context "user is a developer" do
      let(:affiliations) {["developer"]}
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
      let(:affiliations) {["admin"]}
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
      let(:affiliations) {["student", "faculty", "staff", "alumni"]}
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
