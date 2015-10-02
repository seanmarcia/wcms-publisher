require 'spec_helper'

describe 'User' do
  let(:attrs) { {} }
  let(:user) { build :user, attrs }
  subject { user }

  it { should have_field(:biola_id).of_type Integer }
  it { should have_field(:department).of_type String }
  it { should have_field(:email).of_type String }
  it { should have_field(:first_name).of_type String }
  it { should have_field(:last_name).of_type String }
  it { should have_field(:photo_url).of_type String }
  it { should have_field(:title).of_type String }
  it { should have_field(:trogdir_id).of_type String }
  it { should have_field(:username).of_type String }

  it { should belong_to :person }

  # for authentication
  it { should have_field(:current_login_at).of_type DateTime }
  it { should have_field(:last_login_at).of_type DateTime }
  it { should have_field(:login_count).of_type Integer }

  # for roles
  it { should have_field(:entitlements).of_type Array }
  it { should have_field(:affiliations).of_type Array }

  # validations
  it { should validate_uniqueness_of :username }
  it { should validate_presence_of :username }

  # methods
  describe '.netid' do
    it 'should equal user.username' do
      expect(user.netid).to eq(user.username)
    end
  end
  # Considering:
  # it 'should update person attributes with CAS attributes on login'
  # it 'should create person on login if person doesn't already exist'
  # it 'should delegate email to profile'
  # it 'should delegate department to profile'

  # Humanity::Base equivalent methods
  describe '.name' do
    # should return first and last name combined
    subject { user.name }
    context 'when first_name and last_name are populated' do
      let(:attrs) { {first_name: "Bob", last_name: "Jones" } }
      it { should eql "Bob Jones" }
    end
    context 'when first_name and no last_name' do
      let(:attrs) { {first_name: "Bob", last_name: nil } }
      it { should eql "Bob" }
    end
    context 'when first_name and last_name are nil' do
      let(:attrs) { {first_name: nil, last_name: nil } }
      it { should eql "" }
    end
  end

  describe '.has_role?' do
    context 'when passed single symbol' do
      subject { user.has_role?(:admin) }
      context 'and is in affiliations Array' do
        let(:attrs) { {affiliations: ["admin"]} }
        it { should be_truthy }
      end
      context 'and is not in affiliations Array' do
        let(:attrs) { {affiliations: []} }
        it { should be_falsey }
      end
    end

    context 'when passed array of symbols' do
      subject { user.has_role?(:admin, :developer) }
      context 'and all symbols are in entitlements Array' do
        let(:attrs) { {affiliations: ["admin", "developer"]} }
        it { should be_truthy }
      end

      context 'and at least one symbol is in affiliations Array' do
        let(:attrs) { {affiliations: ["admin", "student"]} }
        it { should be_truthy }
      end

      context 'and no symbol is in affiliations Array' do
        let(:attrs) { {affiliations: ["employee", "student"]} }
        it { should be_falsey }
      end
    end
  end

  describe '.relevant_entitlements' do
    subject { user.has_role?(:admin, :developer) }
    context 'with relavant elements' do
      let(:attrs) { {entitlements: ["urn:biola:apps:academic-publisher:admin", "biola:apps:all:developer"]} }
      it { should be_truthy }
    end
    context 'with irrelevant elements' do
      let(:attrs) { {entitlements: ["urn:biola:apps:some-other-app:admin", "developer"]} }
      it { should be_falsey }
    end
  end

  describe '.admin?' do
    subject { user.admin? }
    context 'when affiliations contains admin' do
      let(:attrs) { {affiliations: ["admin","developer"]} }
      it { should be_truthy }
    end

    context 'when affiliations does not contain admin' do
      let(:attrs) { {affiliations: []} }
      it { should be_falsey }
    end
  end

  describe '.developer?' do
    subject { user.developer? }
    context 'when affiliations contains developer' do
      let(:attrs) { {affiliations: ["admin","developer"]} }
      it { should be_truthy }
    end

    context 'when affiliations does not contain developer' do
      let(:attrs) { {affiliations: []} }
      it { should be_falsey }
    end
  end


  describe '.update_login_info!' do
    last_login_at = Time.now - 1.day
    current_login_at = Time.now - 1.hour

    before(:each) do
      @user = FactoryGirl.create :user, last_login_at: last_login_at, current_login_at: current_login_at, login_count: 1
    end

    it 'sets last_login_at to current_login_at' do
      expect{@user.update_login_info!}.to change{@user.last_login_at}
    end
    it 'sets current_login_at to Time.now' do
      expect{@user.update_login_info!}.to change{@user.current_login_at.to_i}.from(current_login_at.to_i).to be_within(5).of(Time.now.to_i)
    end

    it 'increments login_count by 1' do
      expect{@user.update_login_info!}.to change{@user.login_count}.from(1).to(2)
    end

    it 'calls save' do
      expect(@user.save).to be true
    end
  end

  describe '.to_s' do
    it 'returns name' do
      expect(user.to_s).to eq(user.name)
    end
  end
end
