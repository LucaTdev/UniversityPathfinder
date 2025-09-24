module UsersHelper
    # Metodi specifici per gli utenti
  
  def user_avatar(user, options = {})
    size = options[:size] || 150
    classes = options[:class] || "profile-image"
    
    # Se hai un sistema di avatar, utilizzalo qui
    # Altrimenti, usa un placeholder o iniziali
    content_tag :div, class: "#{classes} d-flex align-items-center justify-content-center bg-primary text-white", 
                style: "width: #{size}px; height: #{size}px; border-radius: 50%; font-size: #{size/3}px;" do
      user.first_name.first + user.last_name.first
    end
  end
  
  def user_status_badge(user)
    if user.admin?
      content_tag :span, "Amministratore", class: "badge bg-danger"
    elsif user.student?
      content_tag :span, "Studente", class: "badge bg-primary"
    else
      content_tag :span, "Utente", class: "badge bg-secondary"
    end
  end
  
  def time_since_registration(user)
    return "N/D" unless user.registration_date || user.created_at
    
    date = user.registration_date || user.created_at
    years = (Date.current - date.to_date).to_i / 365
    
    if years > 0
      "#{years} #{'anno'.pluralize(years)}"
    else
      months = (Date.current - date.to_date).to_i / 30
      "#{months} #{'mese'.pluralize(months)}"
    end
  end
end
