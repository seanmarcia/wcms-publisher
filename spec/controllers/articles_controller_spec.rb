require 'spec_helper'
include AuthenticationHelpers

describe ArticlesController do
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

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all articles' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.count
      end
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      before do
        site.authorize!(user, :article_publisher)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees articles from its site' do
        2.times{create :article, site_id: site.id}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees articles only from its site' do
        create :article, site_id: site.id
        create :article
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees no articles not from its site' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql 0
      end
    end

    context 'as an article editor' do
      let(:site) { create :site }
      before do
        site.authorize!(user, :article_editor)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees articles from its site' do
        2.times{create :article, site_id: site.id}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees articles only from its site' do
        create :article, site_id: site.id
        create :article
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees no articles not from its site' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql 0
      end
    end

    context 'as an article author' do
      let(:site) { create :site }
      before do
        site.authorize!(user, :article_author)
        get :index
      end

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees articles from its site' do
        2.times{create :article, site_id: site.id}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees articles only from its site' do
        create :article, site_id: site.id
        create :article
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.where(site_id: site.id).count
      end
      it 'sees no articles not from its site' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql 0
      end
    end

    context 'as an article viewer' do
      let(:affiliations) { ['article_viewer'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all articles' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.count
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }

      it { should be_success }
      it { should have_http_status '200' }
      it 'sees all articles' do
        2.times{create :article}
        expect(Pundit.policy_scope!(user, Article).count).to eql Article.count
      end
    end
  end

  describe 'show' do
    let(:article) { create :article }
    before { get :show, id: article.id }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article viewer' do
      let(:affiliations) { ['article_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }
      it { should redirect_to(edit_article_path(article)) }
      it { should have_http_status '302' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_publisher)
        get :show, id: article.id
      end

      xit { should redirect_to(edit_article_path(article)) }
      xit { should have_http_status '302' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article editor' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_editor)
        get :show, id: article.id
      end

      xit { should redirect_to(edit_article_path(article)) }
      xit { should have_http_status '302' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article author' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_author)
        get :show, id: article.id
      end

      xit { should redirect_to(edit_article_path(article)) }
      xit { should have_http_status '302' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      it { should redirect_to(edit_article_path(article)) }
      it { should have_http_status '302' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end
  end

  describe 'edit' do
    let(:article) { create :article }
    before { get :edit, id: article.id }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article viewer' do
      let(:affiliations) { ['article_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_publisher)
        get :edit, id: article.id
      end
      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article editor' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_editor)
        get :edit, id: article.id
      end
      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article author' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_author)
        get :edit, id: article.id
      end

      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      it { should be_success }
      it { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end
  end

  describe 'update' do
    let(:article) { create :article }
    before { post :update, id: article.id, article: {title: 'MM color sorters'} }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article viewer' do
      let(:affiliations) { ['article_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }
      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_publisher)
        post :update, id: article.id
      end

      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article editor' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_editor)
        post :update, id: article.id
      end

      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an article author' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id, user_id: user.id }
      before do
        site.authorize!(user, :article_author)
        post :update, id: article.id
      end

      xit { should be_success }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      xit { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article)).to eql article
      end
      it 'successfully updates the article' do
        expect(assigns(:article).title).to eql 'MM color sorters'
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

    context 'not as an article viewer' do
      let(:affiliations) { ['article_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }
      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_publisher)
        get :new
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article editor' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_editor)
        get :new
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article author' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_author)
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
    let(:article) { create :article }
    before { post :create, article: {title: 'MM color eaters'} }

    context 'not as an admin' do
      let(:affiliations) { ['student'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'not as an article viewer' do
      let(:affiliations) { ['article_viewer'] }
      it { should_not be_success }
      it { should have_http_status '403' }
    end

    context 'as an article admin' do
      let(:affiliations) { ['article_admin'] }
      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article publisher' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_publisher)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article editor' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_editor)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an article author' do
      let(:site) { create :site }
      let(:article) { create :article, site_id: site.id }
      before do
        site.authorize!(user, :article_author)
        post :create
      end

      it { should be_success }
      it { should have_http_status '200' }
    end

    context 'as an admin' do
      let(:affiliations) { ['admin'] }
      it { should have_http_status '200' }
      it 'assigns @article' do
        expect(assigns(:article).title).to eql 'MM color eaters'
      end
    end
  end
end
