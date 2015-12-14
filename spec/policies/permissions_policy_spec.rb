require 'spec_helper'
describe PermissionsPolicy do
  subject { PermissionsPolicy.new(user, page_edition) }
  let(:user) { build :user, affiliations: affiliations, entitlements: entitlements }
  let(:affiliations) {[]}
  let(:entitlements) {[]}
  let(:page_edition) { create :page_edition, site: site, permissions: page_permissions }
  let(:page_permissions) {[]}
  let(:site) { create :site, permissions: site_permissions }
  let(:site_permissions) {[]}

  # Organized by user permissions, roles and affiliations
  context 'user is an admin' do
    let(:affiliations) { ['admin'] }
    it { expect( subject.page_admin? ).to be_truthy }
    it { expect( subject.page_editor? ).to be_truthy }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_truthy }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_truthy }
    it { expect( subject.site_page_publisher? ).to be_truthy }
    it { expect( subject.site_page_editor? ).to be_truthy }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_truthy }
    it { expect( subject.site_page_editor_for?( site ) ).to be_truthy }
    # it { expect( subject.feature_admin? ).to be_truthy }
    it { expect( subject.site_admin? ).to be_truthy }
    it { expect( subject.site_admin_for?( site ) ).to be_truthy }
  end

  context 'user is a developer' do
    let(:affiliations) { ['developer'] }
    it { expect( subject.page_admin? ).to be_truthy }
    it { expect( subject.page_editor? ).to be_truthy }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_truthy }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_truthy }
    it { expect( subject.site_page_publisher? ).to be_truthy }
    it { expect( subject.site_page_editor? ).to be_truthy }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_truthy }
    it { expect( subject.site_page_editor_for?( site ) ).to be_truthy }
    # it { expect( subject.feature_admin? ).to be_truthy }
    it { expect( subject.site_admin? ).to be_truthy }
    it { expect( subject.site_admin_for?( site ) ).to be_truthy }
  end

  context 'user is neither admin nor developer and has no roles or permissions' do
    it { expect( subject.page_admin? ).to be_falsey }
    it { expect( subject.page_editor? ).to be_falsey }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_falsey }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_falsey }
    it { expect( subject.site_page_publisher? ).to be_falsey }
    it { expect( subject.site_page_editor? ).to be_falsey }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_falsey }
    it { expect( subject.site_page_editor_for?( site ) ).to be_falsey }
    # it { expect( subject.feature_admin? ).to be_falsey }
    it { expect( subject.site_admin? ).to be_falsey }
    it { expect( subject.site_admin_for?( site ) ).to be_falsey }
  end

  context 'page edition has user with permission to edit' do
    let(:page_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :edit)] }
    it { expect( subject.page_admin? ).to be_falsey }
    it { expect( subject.page_editor? ).to be_truthy }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_truthy }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_falsey }
    it { expect( subject.site_page_publisher? ).to be_falsey }
    it { expect( subject.site_page_editor? ).to be_falsey }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_falsey }
    it { expect( subject.site_page_editor_for?( site ) ).to be_falsey }
    # it { expect( subject.feature_admin? ).to be_falsey }
    it { expect( subject.site_admin? ).to be_falsey }
    it { expect( subject.site_admin_for?( site ) ).to be_falsey }
  end

  context 'site has user as a page_edition_editor' do
    let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :page_edition_editor)] }
    it { expect( subject.page_admin? ).to be_falsey }
    it { expect( subject.page_editor? ).to be_truthy }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_truthy }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_truthy }
    it { expect( subject.site_page_publisher? ).to be_falsey }
    it { expect( subject.site_page_editor? ).to be_truthy }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_falsey }
    it { expect( subject.site_page_editor_for?( site ) ).to be_truthy }
    # it { expect( subject.feature_admin? ).to be_falsey }
    it { expect( subject.site_admin? ).to be_falsey }
    it { expect( subject.site_admin_for?( site ) ).to be_falsey }
  end

  context 'site has user as a page_edition_publisher' do
    let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :page_edition_publisher)] }
    it { expect( subject.page_admin? ).to be_falsey }
    it { expect( subject.page_editor? ).to be_truthy }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_truthy }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_truthy }
    it { expect( subject.site_page_publisher? ).to be_truthy }
    it { expect( subject.site_page_editor? ).to be_truthy }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_truthy }
    it { expect( subject.site_page_editor_for?( site ) ).to be_truthy }
    # it { expect( subject.feature_admin? ).to be_falsey }
    it { expect( subject.site_admin? ).to be_falsey }
    it { expect( subject.site_admin_for?( site ) ).to be_falsey }
  end

  # context 'user has role as a feature_admin' do
  #   let(:entitlements) { ["urn:biola:apps:wcms:feature_admin"] }
  #   it { expect( subject.page_admin? ).to be_falsey }
  #   it { expect( subject.page_editor? ).to be_falsey }
  #   it { expect( subject.page_editor_for?( page_edition ) ).to be_falsey }
  #   it { expect( subject.page_publisher_for?( page_edition ) ).to be_falsey }
  #   it { expect( subject.site_page_publisher? ).to be_falsey }
  #   it { expect( subject.site_page_editor? ).to be_falsey }
  #   it { expect( subject.site_page_publisher_for?( site ) ).to be_falsey }
  #   it { expect( subject.site_page_editor_for?( site ) ).to be_falsey }
  #   it { expect( subject.feature_admin? ).to be_truthy }
  #   it { expect( subject.site_admin? ).to be_falsey }
  #   it { expect( subject.site_admin_for?( site ) ).to be_falsey }
  # end

  context 'site has user as a site admin' do
    let(:site_permissions) { [Permission.new(actor_id: user.id, actor_type: 'User', ability: :site_admin)] }
    it { expect( subject.page_admin? ).to be_falsey }
    it { expect( subject.page_editor? ).to be_falsey }
    it { expect( subject.page_editor_for?( page_edition ) ).to be_falsey }
    it { expect( subject.page_publisher_for?( page_edition ) ).to be_falsey }
    it { expect( subject.site_page_publisher? ).to be_falsey }
    it { expect( subject.site_page_editor? ).to be_falsey }
    it { expect( subject.site_page_publisher_for?( site ) ).to be_falsey }
    it { expect( subject.site_page_editor_for?( site ) ).to be_falsey }
    # it { expect( subject.feature_admin? ).to be_falsey }
    it { expect( subject.site_admin? ).to be_truthy }
    it { expect( subject.site_admin_for?( site ) ).to be_truthy }
  end
end
