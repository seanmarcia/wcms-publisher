class PublishersController < ApplicationController
  include SetModifier

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @publishers = Array(Settings.publishers)
  end

end
