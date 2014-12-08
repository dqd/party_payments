class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :load_organizations

  def load_organizations
  	@organizations = Organization.order(:id).all
  end

end
