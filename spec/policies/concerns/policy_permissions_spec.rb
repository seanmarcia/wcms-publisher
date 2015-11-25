require 'spec_helper'
describe "PolicyPermissions" do
  subject { ApplicationPolicy.new(user, nil) }
  let(:user) { build :user, affiliations: affiliations, entitlements: entitlements }
  let(:affiliations) {[]}
  let(:entitlements) {[]}

  context 'user has role as a media_editor' do
    let(:entitlements) { ["urn:biola:apps:wcms-publisher:media_editor"] }
    it { expect( subject.media_editor? ).to be_truthy }
  end

end
