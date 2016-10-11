require 'spec_helper'

describe FirePublishObjectWorker, type: :unit do
  let(:worker) { FirePublishObjectWorker.new }
  Settings.aasm_state_classes.auto_publish.each do |klass|
    context 'with publishable objects' do
      let(:publishable_object) { create klass.underscore.to_sym, attrs }
      let(:attrs) { { publish_at: Time.new(0), archive_at: (Time.now + 60) } }

      it 'publishes the object' do
        publishable_object.set aasm_state: 'approved'

        expect { worker.perform }.to change(UpdateStateWorker.jobs, :size).by 1
      end
    end

    context 'with archivable objects' do
      let(:archivable_object) { create klass.underscore.to_sym, attrs }
      let(:attrs) { { publish_at: Time.new(0), archive_at: (Time.now - 60) } }

      it 'doesnt archive the objects' do
        archivable_object.set aasm_state: 'published'

        expect { worker.perform }.to_not change(UpdateStateWorker.jobs, :size)
      end
    end

    context 'without publishable objects' do
      context 'when object is a draft' do
        let(:drafted_object) { create klass.underscore.to_sym, attrs }
        let(:attrs) { { publish_at: Time.new(0) } }

        it 'doesnt change the objects state' do
          drafted_object.set aasm_state: 'draft'

          expect { worker.perform }.to_not change(UpdateStateWorker.jobs, :size)
        end
      end

      context 'when object approved without a publish date' do
        let(:approved_object) { create klass.underscore.to_sym, attrs }
        let(:attrs) { { publish_at: nil } }

        it 'doesnt change the objects state' do
          approved_object.set aasm_state: 'approved'

          expect { worker.perform }.to_not change(UpdateStateWorker.jobs, :size)
        end
      end

      context 'when object is archived' do
        let(:archived_object) { create klass.underscore.to_sym, attrs }
        let(:attrs) { { publish_at: Time.new(0), archive_at: (Time.now - 60) } }

        it 'doesnt change the objects state' do
          archived_object.set aasm_state: 'archived'

          expect { worker.perform }.to_not change(UpdateStateWorker.jobs, :size)
        end
      end
    end
  end
end
