require 'spec_helper'
include AuthenticationHelpers

describe ActivityTracker::PageEdition do
  subject { ActivityTracker::PageEdition.new }

  let(:user) { create :user, affiliations: ['page_admin'] }
  let(:page_edition) { create :page_edition }

  describe 'track!' do
    context 'when updated' do
      it 'hits the webhook' do
        expect(subject).to receive(:send_webhook!).with("WCMS PageEdition Updated")
        response = subject.track!(user, :updated, page_edition)
        expect(response.success?).to be_truthy
      end
    end

    context 'when destroyed' do
      it 'hits the webhook' do
        expect(subject).to receive(:send_webhook!).with("WCMS PageEdition Destroyed")
        response = subject.track!(user, :destroyed, page_edition)
        expect(response.success?).to be_truthy
      end
    end

    context 'without user' do
      it 'failes with user error and without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        result = subject.track!(nil, :updated, page_edition)
        expect(result.success?).to be_falsy
        expect(result.errors.to_s).to eq('[#<ArgumentError: ActivityTracker::PageEdition -- user must be an instance of User not NilClass>]')
      end
    end

    context 'without action' do
      it 'succeeds without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        result = subject.track!(user, nil, page_edition)
        expect(result.success?).to be_truthy
        expect(result.errors.to_s).to eq('[]')
      end
    end

    context 'without page_edition' do
      it 'fails without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        result = subject.track!(user, :updated, nil)
        expect(result.success?).to be_falsy
        expect(result.errors.to_s).to eq('[#<ArgumentError: ActivityTracker::PageEdition -- page_edition must be an instance of PageEdition not NilClass>]')
      end
    end
  end

end
