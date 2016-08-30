module Segment
  class Service
    include ServiceObject

    attr_reader :errors

    def initialize(options={})
      validate_arguments(options)
      # Options? I'm considering adding support for Segment's integrations and timestamp 
      #   parameters used by .identify and .track and .alias
      #   @integrations = options["integrations"] || { all: true }
      #   @timestamp = options["timestamp"] || nil
      #   def options <-- private method that adds options to hash, 
      #     then merge that hash with the one containing the user_id and traits

      @write_key = options["write_key"] || Settings.analytics.segment.key
      raise "Missing Segment write key! Make sure to add it to the settings file or pass it through to initialize" if write_key.blank?

      @api = Segment::Analytics.new({
            write_key: write_key
        })
      @errors = []
    end

    def identify!(user)
      begin
        identity = Segment::Identity.new(user)
        api.identify({
          user_id: identity.id,
          traits: identity.traits
        })
      rescue => error
        return result_with_errors(error)
      end

      return result_with_success
    end

    def track!(user, event, properties={})
      begin
        identity = Segment::Identity.new(user)
        api.track({
          user_id: identity.id,
          event: event,
          properties: properties
        })
      rescue => error
        return result_with_errors(error)
      end

      return result_with_success
    end

    private

    attr_accessor :api, :write_key

    def validate_arguments(options)
      raise(ArgumentError, "Invalid argument. Must pass a hash or nothing.") unless options.is_a?(Hash)
    end
  end

end
