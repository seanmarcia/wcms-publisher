require 'spec_helper'
include AuthenticationHelpers

describe FeaturesController do
  subject { response }

  let(:affiliations) { [] }
  let(:user) { create :user, affiliations: affiliations }

  before { set_current_user user }

  describe 'index' do
    before { get :index }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature admin' do
      let(:affiliations) { ['feature_admin'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all features' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.count
      end
    end

    context 'as a feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      before do
        site.authorize!(user, :feature_publisher)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees features from its site' do
        2.times{create :feature, feature_location_id: feature_location.id}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees features only from its site' do
        create :feature, feature_location_id: feature_location.id
        create :feature
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees no features not from its site' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql 0
      end
    end

    context 'as a feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      before do
        site.authorize!(user, :feature_editor)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees features from its site' do
        2.times{create :feature, feature_location_id: feature_location.id}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees features only from its site' do
        create :feature, feature_location_id: feature_location.id
        create :feature
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees no features not from its site' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql 0
      end
    end

    context 'as a feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      before do
        site.authorize!(user, :feature_author)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees features from its site' do
        2.times{create :feature, feature_location_id: feature_location.id}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees features only from its site' do
        create :feature, feature_location_id: feature_location.id
        create :feature
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.where(feature_location_id: feature_location.id).count
      end
      it 'sees no features not from its site' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql 0
      end
    end

    context 'as a feature viewer' do
      let(:affiliations) { ['feature_viewer'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all features' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.count
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all features' do
        2.times{create :feature}
        expect(Pundit.policy_scope!(user, Feature).count).to eql Feature.count
      end
    end
  end

  describe 'show' do
    context 'not as an admin' do
      let(:feature) { create :feature }
      let(:affiliations) { ['student'] }
      before { get :show, id: feature.id }

      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature viewer' do
      let(:feature) { create :feature }
      let(:affiliations) { ['feature_viewer'] }
      before { get :show, id: feature.id }

      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature admin' do
      let(:affiliations) { ['feature_admin'] }
      let(:feature) { create :feature }
      before { get :show, id: feature.id }

      it { should redirect_to(edit_feature_path(feature)) }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_publisher)
        get :show, id: feature.id
      end

      it { should redirect_to(edit_feature_path(feature)) }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_editor)
        get :show, id: feature.id
      end

      it { should redirect_to(edit_feature_path(feature)) }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_author)
        get :show, id: feature.id
      end

      it { should redirect_to(edit_feature_path(feature)) }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      let(:feature) { create :feature }
      before { get :show, id: feature.id }

      it { should redirect_to(edit_feature_path(feature)) }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end
  end

  describe 'edit' do
    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      let(:feature) { create :feature }
      before { get :edit, id: feature.id }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature viewer' do
      let(:affiliations) { ['feature_viewer'] }
      let(:feature) { create :feature }
      before { get :edit, id: feature.id }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature admin' do
      let(:affiliations) { ['feature_admin'] }
      let(:feature) { create :feature }
      before { get :edit, id: feature.id }
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_publisher)
        get :edit, id: feature.id
      end
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_editor)
        get :edit, id: feature.id
      end
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as a feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_author)
        get :edit, id: feature.id
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      let(:feature) { create :feature }
      before { get :edit, id: feature.id }
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end
  end

  describe 'update' do
    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      let(:feature) { create :feature }
      before { post :update, id: feature.id, feature: {title: 'MM color sorters'} }

      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an feature viewer' do
      let(:affiliations) { ['feature_viewer'] }
      let(:feature) { create :feature }
      before { post :update, id: feature.id, feature: {title: 'MM color sorters'} }

      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an feature admin' do
      let(:affiliations) { ['feature_admin'] }
      let(:feature) { create :feature }
      before { post :update, id: feature.id, feature: {title: 'MM color sorters'} }

      it { should be_redirect }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_publisher)
        post :update, id: feature.id
      end

      it { should be_redirect }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_editor)
        post :update, id: feature.id
      end

      it { should be_redirect }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_author)
        post :update, id: feature.id
      end

      it { should be_redirect }
      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      let(:feature) { create :feature }
      before { post :update, id: feature.id, feature: {title: 'MM color sorters'} }

      it { should have_http_status '302' }
      it 'assigns @feature' do
        expect(assigns(:feature)).to eql feature
      end
      it 'successfully updates the feature' do
        expect(assigns(:feature).title).to eql 'MM color sorters'
      end
    end
  end

  describe 'new' do
    before { get :new }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'not as a feature viewer' do
      let(:affiliations) { ['feature_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature admin' do
      let(:affiliations) { ['feature_admin'] }
      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_publisher)
        get :new
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_editor)
        get :new
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_author)
        get :new
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      it { should be_success }
      it { should have_http_status '200' }
    end
  end

  describe 'create' do
    let(:feature) { create :feature }
    before { post :create, feature: {title: 'MM color eaters'} }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'not as a feature viewer' do
      let(:affiliations) { ['feature_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as a feature admin' do
      let(:affiliations) { ['feature_admin'] }
      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature publisher' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_publisher)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature editor' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_editor)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as a feature author' do
      let(:site) { create :site }
      let(:feature_location) { create :feature_location, site_id: site.id }
      let(:feature) { create :feature, feature_location_id: feature_location.id }
      before do
        site.authorize!(user, :feature_author)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      it { should have_http_status '200' }
      it 'assigns @feature' do
        expect(assigns(:feature).title).to eql 'MM color eaters'
      end
    end
  end
end
