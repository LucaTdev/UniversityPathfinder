class FaqNotificationSettingsController < ApplicationController
  before_action :require_user_json!

  def show
    render json: { enabled: notifications_enabled? }
  end

  def update
    enabled = normalize_enabled_param
    return render json: { error: "invalid_enabled" }, status: :unprocessable_entity if enabled.nil?

    setting = current_user.faq_notification_setting || current_user.build_faq_notification_setting
    setting.enabled = enabled

    if setting.save
      render json: { enabled: setting.enabled }
    else
      render json: { error: "invalid", messages: setting.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def notifications_enabled?
    value = current_user&.faq_notification_setting&.enabled
    value.nil? ? true : value
  end

  def normalize_enabled_param
    raw = params.key?(:enabled) ? params[:enabled] : params.dig(:faq_notification_setting, :enabled)
    return nil if raw.nil?

    ActiveModel::Type::Boolean.new.cast(raw)
  end

  def require_user_json!
    return if logged_in?
    render json: { error: "unauthorized", login_url: login_path }, status: :unauthorized
  end
end
