require 'spec_helper'

describe UpdateStateWorker, type: :unit do
  # Dynamically testing all of the auto_archive classes as detailed in settings
  Settings.aasm_state_classes.auto_archive.each do |klass|
    context 'with archivable objects' do
      let(:attrs) { { publish_at: Time.new(0), archive_at: (Time.now - 60) } }

      context "as a #{klass}" do
        let(:archivable_object) { create klass.underscore.to_sym, attrs }

        it 'publishes the object' do
          archivable_object.set aasm_state: 'published'
          UpdateStateWorker.new.perform(archivable_object.class.to_s, archivable_object.id)
          expect(archivable_object.reload.aasm_state).to eq 'archived'
        end
      end
    end

    context 'without archivable objects' do
      context "as a #{klass} as draft" do
        let(:drafe_object) { create klass.underscore.to_sym, publish_at: Date.tomorrow, aasm_state: 'draft' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(drafe_object.class.to_s, drafe_object.id)
          expect(drafe_object.reload.aasm_state).to eq 'draft'
        end
      end

      context "as a #{klass} as published without archive" do
        let(:published_object) { create klass.underscore.to_sym, publish_at: Time.new(0), aasm_state: 'published' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(published_object.class.to_s, published_object.id)
          expect(published_object.reload.aasm_state).to eq 'published'
        end
      end

      context "as a #{klass} as archived" do
        let(:archived_object) { create klass.underscore.to_sym, publish_at: Time.new(0), archive_at: Time.new(1), aasm_state: 'archived' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(archived_object.class.to_s, archived_object.id)
          expect(archived_object.reload.aasm_state).to eq 'archived'
        end
      end
    end
  end

  # Dynamically testing all of the auto_publish classes as detailed in settings
  Settings.aasm_state_classes.auto_publish.each do |klass|
    context 'with publishable objects' do
      let(:attrs) { { publish_at: Time.new(0), archive_at: (Time.now + 60) } }

      context "as a #{klass}" do
        let(:publishable_object) { create klass.underscore.to_sym, attrs }

        it 'publishes the object' do
          publishable_object.set aasm_state: 'approved'
          UpdateStateWorker.new.perform(publishable_object.class.to_s, publishable_object.id)
          expect(publishable_object.reload.aasm_state).to eq 'published'
        end
      end
    end

    context 'without publishable objects' do
      context "as a #{klass} as draft" do
        let(:drafe_object) { create klass.underscore.to_sym, publish_at: Date.tomorrow, aasm_state: 'draft' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(drafe_object.class.to_s, drafe_object.id)
          expect(drafe_object.reload.aasm_state).to eq 'draft'
        end
      end

      context "as a #{klass} as published without archive" do
        let(:published_object) { create klass.underscore.to_sym, publish_at: Time.new(0), aasm_state: 'published' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(published_object.class.to_s, published_object.id)
          expect(published_object.reload.aasm_state).to eq 'published'
        end
      end

      context "as a #{klass} as archived" do
        let(:archived_object) { create klass.underscore.to_sym, publish_at: Time.new(0), archive_at: Time.new(1), aasm_state: 'archived' }

        it 'does nothing to the object' do
          UpdateStateWorker.new.perform(archived_object.class.to_s, archived_object.id)
          expect(archived_object.reload.aasm_state).to eq 'archived'
        end
      end
    end
  end
end
