class FaqVotesController < ApplicationController
  before_action :require_user_json!
  before_action :set_faq

  # UI API: crea/aggiorna il voto dell'utente corrente.
  # Se l'utente invia lo stesso voto già presente, lo rimuoviamo (toggle).
  def upsert
    value = normalize_value(params[:value])
    return render json: { error: "invalid_vote" }, status: :unprocessable_entity if value.nil?

    vote = FaqVote.find_or_initialize_by(faq: @faq, user: current_user)

    if vote.persisted? && vote.value == value
      vote.destroy!
      return render json: payload_for(@faq, current_value: nil)
    end

    vote.value = value
    vote.save!
    render json: payload_for(@faq, current_value: value)
  end

  def destroy
    vote = FaqVote.find_by(faq: @faq, user: current_user)
    vote&.destroy!
    render json: payload_for(@faq, current_value: nil)
  end

  private

  def require_user_json!
    return if user_signed_in?
    render json: { error: "unauthorized", login_url: login_path }, status: :unauthorized
  end

  def set_faq
    @faq = Faq.find(params[:faq_id])
  end

  def normalize_value(raw)
    case raw.to_s
    when "1", "up" then 1
    when "-1", "down" then -1
    else nil
    end
  end

  def payload_for(faq, current_value:)
    up = FaqVote.where(faq_id: faq.id, value: 1).count
    down = FaqVote.where(faq_id: faq.id, value: -1).count

    current =
      case current_value
      when 1 then "up"
      when -1 then "down"
      else nil
      end

    { faq_id: faq.id, up: up, down: down, current: current }
  end
end
