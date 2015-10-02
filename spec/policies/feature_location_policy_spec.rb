require 'spec_helper'
describe FeatureLocationPolicy do
  subject { FeatureLocationPolicy.new(user, feature_location) }
  let(:user) { build :user, affiliations: affiliations, entitlements: entitlements }
  let(:affiliations) {[]}
  let(:entitlements) {[]}
  let(:feature_location) { build :feature_location, site: site }
  let(:site) { create :site, permissions: site_permissions}
  let(:site_permissions) {[]}

  describe 'affiliation and entitlement based permissions' do
    permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
      context "user is a developer" do
        let(:affiliations) {["developer"]}
        it { expect(FeatureLocationPolicy).to permit(user) }
      end

      context "user is an admin" do
        let(:affiliations) {["admin"]}
        it { expect(FeatureLocationPolicy).to permit(user) }
      end

      context "user is both an admin and a developer" do
        let(:affiliations) {["admin", "developer"]}
        it { expect(FeatureLocationPolicy).to permit(user) }
      end
    end

    context "user is a site_admin" do
      let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin)] }
      it { expect(subject).to sanction(:create) }
      it { expect(subject).to sanction(:new) }
      it { expect(subject).to sanction(:index) }
      it { expect(subject).to sanction(:show) }
      it { expect(subject).to sanction(:edit) }
      it { expect(subject).to sanction(:update) }
      it { expect(subject).to sanction(:destroy) }
    end

    context "user is a page edition admin" do
      let(:entitlements) { ["urn:biola:apps:wcms:feature_admin"] }
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).to sanction(:destroy)}
    end
  end
end
