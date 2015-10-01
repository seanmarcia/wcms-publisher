require 'spec_helper'
describe SitePolicy do
  subject { SitePolicy.new(user, site) } # describe class uses the parent describe class: SitePolicy
  let(:user) { build :user, attrs }
  let(:site) { create :site, permissions: [permissions] }
  let(:permissions) { site.permissions.new }

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

    context "user is any other affiliation" do
      let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
      let(:permissions) { Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin) }
      it { expect(subject).to sanction(:create)}
      it { expect(subject).to sanction(:new)}
      it { expect(subject).to sanction(:index)}
      it { expect(subject).to sanction(:search)}
      it { expect(subject).to sanction(:show)}
      it { expect(subject).to sanction(:edit)}
      it { expect(subject).to sanction(:update)}
      it { expect(subject).not_to sanction(:destroy)}
    end
  end

  # describe "can_manage?" do
  #   subject { SitePolicy.new(user, site) }
  #   let(:site) { build :site }
  #   let(:user) { build :user, attrs }
  #   let(:permissions) { site.permissions.new(actor_id: user.id, actor_type: 'User', ability: ability)}

  #   context "user is a developer" do
  #     let(:attrs) {{affiliations: ["developer"]}}
  #     let(:ability) { :site_admin }
  #     it { expect(subject.can_manage?(nil)).to be_truthy }
  #     it { expect(subject.can_manage?(:form)).to be_truthy }
  #     it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
  #     it { expect(subject.can_manage?(:permissions)).to be_truthy }
  #     it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:event_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:article_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
  #   end

  #   context "user is an admin" do
  #     let(:attrs) {{affiliations: ["admin"]}}
  #     it { expect(subject.can_manage?(nil)).to be_truthy }
  #     it { expect(subject.can_manage?(:form)).to be_truthy }
  #     it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
  #     it { expect(subject.can_manage?(:permissions)).to be_truthy }
  #     it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:event_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:article_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
  #   end

  #   context "user is an page admin" do
  #     let(:attrs) {{role: ["page_admin"]}}
  #     it { expect(subject.can_manage?(nil)).to be_truthy }
  #     it { expect(subject.can_manage?(:form)).to be_truthy }
  #     it { expect(subject.can_manage?(:activity_logs)).to be_truthy }
  #     it { expect(subject.can_manage?(:permissions)).to be_truthy }
  #     it { expect(subject.can_manage?(:page_edition_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:event_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:article_categories)).to be_truthy }
  #     it { expect(subject.can_manage?(:feature_locations)).to be_truthy }
  #   end

  #   context "user is any other affiliation" do
  #     let(:attrs) {{affiliations: ["student", "faculty", "staff", "alumni"]}}
  #     it { expect(subject.can_manage?(nil)).to be_truthy }
  #     it { expect(subject.can_manage?(:form)).to be_truthy }
  #     it { expect(subject.can_manage?(:activity_logs)).to be_falsey }
  #     it { expect(subject.can_manage?(:permissions)).to be_falsey }
  #     it { expect(subject.can_manage?(:page_edition_categories)).to be_falsey }
  #     it { expect(subject.can_manage?(:event_categories)).to be_falsey }
  #     it { expect(subject.can_manage?(:article_categories)).to be_falsey }
  #     it { expect(subject.can_manage?(:feature_locations)).to be_falsey }
  #   end
  # end
end
