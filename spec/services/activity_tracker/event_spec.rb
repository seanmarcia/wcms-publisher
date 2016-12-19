require 'spec_helper'
include AuthenticationHelpers

describe ActivityTracker::Event do
  subject { ActivityTracker::Event.new }

  let(:user) { create :user, affiliations: ['page_admin'] }
  let(:event) { create :event }

  describe 'track!' do
    context 'when created' do
      it 'hits the webhook' do
        expect(subject).to receive(:send_webhook!).with("Event Created in WCMS")
        expect(subject).to receive(:track_in_segment).with("Event Created in WCMS")
        response = subject.track!(user, :created, event)
        expect(response.success?).to be_truthy
      end
    end

    context 'when updated' do
      it 'hits the webhook' do
        expect(subject).to receive(:send_webhook!).with("Event Updated in WCMS")
        expect(subject).to receive(:track_in_segment).with("Event Updated in WCMS")
        response = subject.track!(user, :updated, event)
        expect(response.success?).to be_truthy
      end
    end

    context 'without user' do
      it 'failes with user error and without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        expect(subject).to_not receive(:track_in_segment)
        result = subject.track!(nil, :updated, event)
        expect(result.success?).to be_falsy
        expect(result.errors.to_s).to eq('[#<ArgumentError: ActivityTracker::Event -- user must be an instance of User not NilClass>]')
      end
    end

    context 'without action' do
      it 'succeeds without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        expect(subject).to_not receive(:track_in_segment)
        result = subject.track!(user, nil, event)
        expect(result.success?).to be_truthy
        expect(result.errors.to_s).to eq('[]')
      end
    end

    context 'without event' do
      it 'fails without hitting the hook' do
        expect(subject).to_not receive(:send_webhook!)
        expect(subject).to_not receive(:track_in_segment)
        result = subject.track!(user, :updated, nil)
        expect(result.success?).to be_falsy
        expect(result.errors.to_s).to eq('[#<ArgumentError: ActivityTracker::Event -- event must be an instance of Event not NilClass>]')
      end
    end
  end

end
