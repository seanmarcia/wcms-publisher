require 'spec_helper'
describe SitePolicy do
  subject { SitePolicy.new(user, site) }
  let(:user) { build :user, attrs }
  let(:attrs) {{}}
  let(:site) { create :site, permissions: [permissions] }
  let(:permissions) { }

  describe 'affiliation based permissions' do
    permissions :index?, :show?, :create?, :new?, :update?, :edit? do
      context "user is a developer" do
        let(:attrs) {{affiliations: ["developer"]}}
        it { expect(SitePolicy).to permit(user) }
      end

      context "user is an admin" do
        let(:attrs) {{affiliations: ["admin"]}}
        it { expect(SitePolicy).to permit(user) }
      end

      context "user is both an admin and a developer" do
        let(:attrs) {{affiliations: ["admin", "developer"]} }
        it { expect(SitePolicy).to permit(user) }
      end
    end
  end

  describe 'role based permissions' do
    context "user is any other affiliation and has no roles" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      let(:permissions) { }
      it { expect(subject).not_to sanction(:create) }
      it { expect(subject).not_to sanction(:new) }
      it { expect(subject).not_to sanction(:index) }
      it { expect(subject).not_to sanction(:search) }
      it { expect(subject).not_to sanction(:show) }
      it { expect(subject).not_to sanction(:edit) }
      it { expect(subject).not_to sanction(:update) }
      it { expect(subject).not_to sanction(:destroy) }
    end

    context "user is any other affiliation but is a site_admin" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      let(:permissions) { Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin) }
      it { expect(subject).to sanction(:create) }
      it { expect(subject).to sanction(:new) }
      it { expect(subject).to sanction(:index) }
      it { expect(subject).to sanction(:search) }
      it { expect(subject).to sanction(:show) }
      it { expect(subject).to sanction(:edit) }
      it { expect(subject).to sanction(:update) }
      it { expect(subject).not_to sanction(:destroy) }
    end

    context "user is an admin and a site_admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      let(:permissions) { Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin) }
      it { expect(subject).to sanction(:create) }
      it { expect(subject).to sanction(:new) }
      it { expect(subject).to sanction(:index) }
      it { expect(subject).to sanction(:search) }
      it { expect(subject).to sanction(:show) }
      it { expect(subject).to sanction(:edit) }
      it { expect(subject).to sanction(:update) }
      it { expect(subject).not_to sanction(:destroy) }
    end

    context "user is a developer and a site_admin" do
      let(:attrs) {{affiliations: ["developer"]}}
      let(:permissions) { Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin) }
      it { expect(subject).to sanction(:create) }
      it { expect(subject).to sanction(:new) }
      it { expect(subject).to sanction(:index) }
      it { expect(subject).to sanction(:search) }
      it { expect(subject).to sanction(:show) }
      it { expect(subject).to sanction(:edit) }
      it { expect(subject).to sanction(:update) }
      it { expect(subject).not_to sanction(:destroy) }
    end
  end

  describe "can_manage?" do
    let(:site) { build :site, permissions: [permissions], has_page_editions: true, has_events: true, has_articles: true, has_features: true}
    context "user is a developer" do
      let(:attrs) {{affiliations: ["developer"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
      it { expect(subject.can_manage?(:event_categories)).to be_truthy }
      it { expect(subject.can_manage?(:article_categories)).to be_truthy }
      it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
    end

    context "user is an admin" do
      let(:attrs) {{affiliations: ["admin"]}}
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
      it { expect(subject.can_manage?(:event_categories)).to be_truthy }
      it { expect(subject.can_manage?(:article_categories)).to be_truthy }
      it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
    end

    context "user is an page admin" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      let(:permissions) { Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin) }
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_truthy }
      it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
      it { expect(subject.can_manage?(:event_categories)).to be_truthy }
      it { expect(subject.can_manage?(:article_categories)).to be_truthy }
      it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
    end

    context "user is any other affiliation" do
      let(:permissions) { nil }
      it { expect(subject.can_manage?(nil)).to be_truthy }
      it { expect(subject.can_manage?(:form)).to be_truthy }
      it { expect(subject.can_manage?(:logs)).to be_truthy }
      it { expect(subject.can_manage?(:permissions)).to be_falsey }
      it { expect(subject.can_manage?(:page_edition_categories)).to be_falsey }
      it { expect(subject.can_manage?(:event_categories)).to be_falsey }
      it { expect(subject.can_manage?(:article_categories)).to be_falsey }
      it { expect(subject.can_manage?(:feature_locations)).to be_falsey }
    end
  end
end
