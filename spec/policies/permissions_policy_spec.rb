require 'spec_helper'
describe PermissionsPolicy do
  subject { described_class }
  let(:user) { build :user, attrs }

  describe 'page_admin?' do
    context 'user is an admin' do
      let(:attrs) {{affiliations: ["admin"]}}
      xit { expect(page_admin?).to be_truthy}
    end
  end
end
