require 'spec_helper'
include AuthenticationHelpers

describe ActorsController do
  let(:page) { create :page_edition }
  let(:person) { create :person }

  describe "POST #create" do
    def create_actor(person_id=nil)
      post :create, page_edition_id: page.id, _person_id: person_id
      page.reload
    end

    context "as admin" do
      let(:admin) { create :user, affiliations: [:admin]}
      before do
        set_current_user(admin)
      end

      context "person does not exist" do
        it "shows error and does not create permission" do
          create_actor('1234')
          expect(flash[:error]).to eql "Person was not found."
          expect(page.permissions.count).to eql 0
        end
      end
      context "person has no user tied to it" do
        it "shows error and does not create permission" do
          create_actor(person.id)
          expect(flash[:warning]).to match "needs to log in to"
          expect(page.permissions.count).to eql 0
        end
      end

      context "person is tied to user" do
        let!(:user) { create :user, person_id: person.id }

        it "gives user permission to the parent object" do
          create_actor(person.id)
          expect(page.permissions.count).to eql 1
          expect(page.has_permission?(user)).to be true
          expect(flash[:info]).to match "permissions have been successfully saved"
        end
      end
    end

    context "as non-admin" do
      it "denies access" do
        create_actor(person.id)
        expect(response.code).to eql "401"
      end
    end
  end


  describe "DELETE #destroy" do
    let(:user) { create :user }

    def delete_actor(user_id=nil)
      delete :destroy, page_edition_id: page.id, id: user_id, role: :all_roles
      page.reload
    end

    def delete_actor_role(user_id=nil)
      delete :destroy, page_edition_id: page.id, id: user_id, role: :edit
      page.reload
    end

    before { page.authorize(user, :edit) }

    context "as admin" do
      before { set_current_user(admin) }

      let(:admin) { create :user, affiliations: [:admin]}

      it "removes all permissions for user" do
        expect(page.permissions.count).to eql 1
        expect(page.has_permission?(user)).to be true
        delete_actor(user.id)
        expect(page.permissions.count).to eql 0
        expect(page.has_permission?(user)).to be false
      end

      it "removes edit permissions for user" do
        expect(page.permissions.count).to eql 1
        expect(page.has_permission?(user)).to be true
        delete_actor_role(user.id)
        expect(page.permissions.count).to eql 0
        expect(page.has_permission?(user)).to be false
      end
    end

    context "as non-admin" do
      it "denies access" do
        delete_actor('123')
        expect(response.code).to eql "401"
      end
    end
  end
end
