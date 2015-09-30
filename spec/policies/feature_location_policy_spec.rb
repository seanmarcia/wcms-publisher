require 'spec_helper'
describe FeatureLocationPolicy do
  subject { described_class } # describe class uses the parent describe class: FeatureLocationPolicy
  let(:user) { build :user, attrs }

  # TODO: figure out how to handle the resolve method and scoping
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

end
