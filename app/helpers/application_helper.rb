module ApplicationHelper
    # Helper per verificare se l'utente può modificare il profilo
  def can_edit_profile?
    return false unless user_signed_in? && @user
    
    # L'utente può modificare il proprio profilo o se è admin
    current_user.id == @user.id || current_user.admin?
  end
  
  # Helper per verificare se l'utente può eliminare il profilo
  def can_delete_profile?
    return false unless user_signed_in? && @user
    
    # Solo il proprietario del profilo può eliminarlo
    current_user.id == @user.id
  end
  
  # Helper per formattare la data di iscrizione
  def formatted_registration_date(user)
    return "N/D" unless user.registration_date || user.created_at
    
    date = user.registration_date || user.created_at
    date.strftime("%d %B %Y")
  end
  
  # Helper per ottenere l'icona del ruolo
  def role_icon(user)
    case user.role
    when User::ROLE_STUDENT
      '<i class="fas fa-graduation-cap"></i>'.html_safe
    when User::ROLE_ADMIN
      '<i class="fas fa-user-shield"></i>'.html_safe
    else
      '<i class="fas fa-user"></i>'.html_safe
    end
  end
end
