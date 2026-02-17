class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Handle ActiveRecord::RecordNotFound errors globally
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(exception)
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false }
      format.json { render json: {error: "Record not found", message: exception.message}, status: :not_found }
      format.any { head :not_found }
    end
  end
end
