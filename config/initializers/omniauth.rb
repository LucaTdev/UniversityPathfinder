google_client_id = ENV["GOOGLE_CLIENT_ID"].presence || (Rails.env.test? ? "test-google-client-id" : nil)
google_client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence || (Rails.env.test? ? "test-google-client-secret" : nil)

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true

if google_client_id.present? && google_client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      google_client_id,
      google_client_secret,
      scope: "openid email profile",
      prompt: "select_account"
  end
else
  Rails.logger.warn("Google OAuth non configurato: GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET mancanti.")
end
