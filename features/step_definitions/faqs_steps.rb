require "cgi"
require "uri"

module FaqFeatureHelpers
  def login_as(user, redirect_to:)
    Capybara.reset_sessions!
    visit "/login"
    fill_in("Email", with: user.email)
    fill_in("Password", with: "password123")
    click_button("Accedi")
    page.assert_no_current_path("/login", wait: 5)
    visit redirect_to
  end

  def path_only
    URI.parse(page.current_url).path
  end

  def assert_record(condition, message)
    raise message unless condition
  end

  def flow_category
    @flow_category ||= FaqCategory.where("lower(name) = ?", @category.downcase).first_or_create!(name: @category)
  end

  def create_flow_suggestion!
    @suggestion ||= FaqSuggestion.create!(
      user: @user,
      domanda: @question,
      dettagli: @details,
      risposta: @answer,
      categoria: @category,
      faq_category: flow_category
    )
  end

  def create_published_flow_faq!
    create_flow_suggestion!
    return @faq if @faq.present?

    @faq = Faq.create!(
      domanda: @question,
      risposta: @answer,
      categoria: flow_category.name,
      faq_category: flow_category
    )

    @suggestion.update!(
      status: :accettata,
      faq: @faq,
      faq_category: flow_category
    )

    @faq
  end

  def create_updated_flow_faq!
    create_published_flow_faq!
    return @faq if @faq.domanda == @edited_question && @faq.risposta == @edited_answer

    @faq.update!(
      domanda: @edited_question,
      risposta: @edited_answer
    )

    @faq.reload
  end

  def create_translated_flow_faq!
    create_updated_flow_faq!
    return @translation if @translation.present?

    @translation = @faq.faq_translations.create!(
      locale: "en",
      domanda: @translated_question,
      risposta: @translated_answer
    )
  end
end

World(FaqFeatureHelpers)

Dato("che esistono un utente registrato e un amministratore per il flusso FAQ") do
  token = SecureRandom.hex(4)

  @question = "Come recupero il badge universitario?"
  @details = "Ho smarrito il badge e devo richiederne uno nuovo."
  @answer = "Recati in segreteria con un documento e richiedi il duplicato."
  @edited_question = "Come sostituisco il badge universitario?"
  @edited_answer = "Prenota in segreteria e richiedi un nuovo badge con documento valido."
  @translated_question = "How do I replace my university badge?"
  @translated_answer = "Book an appointment with the student office and request a new badge with a valid ID."
  @category = "Segreteria"

  @user = User.create!(
    first_name: "Test",
    last_name: "User",
    email: "faq-user@example.com",
    password: "password123",
    password_confirmation: "password123",
    registration_date: Date.current,
    role: User::ROLE_STUDENT,
    terms_accepted: true
  )

  @admin = User.create!(
    first_name: "Admin",
    last_name: "User",
    email: "faq-admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    registration_date: Date.current,
    role: User::ROLE_ADMIN,
    terms_accepted: true
  )
end

Dato("esiste una FAQ aggiuntiva per verificare filtro e ricerca") do
  @distractor_question = "Come prenoto un'aula studio? #{SecureRandom.hex(4)}"
  @distractor_answer = "Usa il portale prenotazioni dell'ateneo."
  @distractor_faq = Faq.create!(
    domanda: @distractor_question,
    risposta: @distractor_answer,
    faq_category: FaqCategory.general!
  )
end

Dato("che esiste una FAQ pubblicata nel flusso FAQ") do
  create_published_flow_faq!
  assert_record(@suggestion.accettata?, "Il suggerimento FAQ non e' accettato nel setup")
  assert_record(@faq.present?, "La FAQ pubblicata non e' stata preparata nel setup")
end

Dato("che esiste una FAQ aggiornata nel flusso FAQ") do
  create_updated_flow_faq!
  assert_record(@faq.domanda == @edited_question, "La FAQ aggiornata non e' stata preparata nel setup")
end

Dato("che esiste una FAQ tradotta nel flusso FAQ") do
  create_translated_flow_faq!
  assert_record(@translation.present?, "La traduzione non e' stata preparata nel setup")
end

Quando("l'utente registrato accede alla sua area FAQ e invia un suggerimento") do
  login_as(@user, redirect_to: "/user/faqs")

  page.assert_text("Utente registrato", wait: 5)
  page.assert_text(@user.first_name, wait: 5)
  click_button("Suggerisci FAQ")

  page.assert_selector("#suggest-faq-form.show", wait: 5)

  within("#suggest-faq-form") do
    fill_in("suggest_domanda", with: @question)
    fill_in("suggest_dettagli", with: @details)
    fill_in("suggest_risposta", with: @answer)
    fill_in("suggest_categoria", with: @category)
  end

  click_button("Invia suggerimento")

  page.assert_text("I tuoi suggerimenti", wait: 5)
  page.assert_text(@question, wait: 5)
  page.assert_text(@category, wait: 5)
  page.assert_text("In attesa", wait: 5)

  @suggestion = FaqSuggestion.order(:id).last
  assert_record(@suggestion.present?, "Suggerimento FAQ non creato")
  assert_record(@suggestion.user_id == @user.id, "Il suggerimento non appartiene all'utente corretto")
  assert_record(@suggestion.attesa?, "Il suggerimento non e' in attesa")
end

Quando("l'amministratore pubblica il suggerimento come FAQ") do
  login_as(@admin, redirect_to: "/admin/faqs")

  page.assert_text("Amministrazione FAQ", wait: 5)
  page.assert_text("Suggerimento ##{@suggestion.id}", wait: 5)

  within("form[action='/admin/faq_suggestions/#{@suggestion.id}/publish']") do
    fill_in("publish_categoria", with: @category)
    fill_in("publish_domanda", with: @question)
    fill_in("publish_risposta", with: @answer)
    click_button("Pubblica come FAQ")
  end

  page.assert_text("Amministrazione FAQ", wait: 5)
  visit "/admin/faqs"
  page.assert_text(@question, wait: 5)
  page.assert_text(@answer, wait: 5)
  page.assert_text(@category, wait: 5)
  page.assert_no_text("Suggerimento ##{@suggestion.id}", wait: 5)

  @suggestion.reload
  @faq = @suggestion.faq
  assert_record(@suggestion.accettata?, "Il suggerimento non e' stato accettato")
  assert_record(@faq.present?, "La FAQ non e' stata creata")
end

Quando("l'utente registrato vede la notizia di pubblicazione") do
  login_as(@user, redirect_to: "/home/meteo")

  page.assert_text("News", wait: 5)
  page.assert_text("Pubblicazione nuova FAQ", wait: 5)
  page.assert_text(@question, wait: 5)
end

Quando("l'amministratore modifica la FAQ pubblicata") do
  login_as(@admin, redirect_to: "/admin/faqs")

  within(".faq-card", text: @question) do
    find("button[title='Modifica FAQ']").click
  end

  page.assert_selector("#faq-form", visible: true, wait: 5)

  within("#faq-form") do
    fill_in("faq_domanda", with: @edited_question)
    fill_in("faq_risposta", with: @edited_answer)
    click_button("Aggiorna FAQ")
  end

  page.assert_no_text(@question, wait: 5)
  page.assert_text(@edited_question, wait: 5)
  page.assert_text(@edited_answer, wait: 5)

  @faq.reload
  assert_record(@faq.domanda == @edited_question, "La domanda FAQ non e' stata aggiornata")
  assert_record(@faq.risposta == @edited_answer, "La risposta FAQ non e' stata aggiornata")
end

Quando("l'utente registrato vede la notizia di aggiornamento") do
  login_as(@user, redirect_to: "/home/meteo")

  page.assert_text("Aggiornamento FAQ", wait: 5)
  page.assert_text(@edited_question, wait: 5)
end

Quando("l'amministratore aggiunge una traduzione inglese alla FAQ") do
  login_as(@admin, redirect_to: "/admin/faqs")

  within(".faq-card", text: @edited_question) do
    find("button[title='Traduzioni']").click
  end

  page.assert_selector("#faq-translations-modal.show", wait: 5)

  within("#faq-translations-modal") do
    page.assert_text("Traduzioni FAQ", wait: 5)
    english_row = find(".list-group-item", text: "English")
    english_row.find("button[title='Aggiungi traduzione']").click

    domanda_field = find_field("faq-translation-domanda", wait: 5)
    risposta_field = find_field("faq-translation-risposta", wait: 5)
    assert_record(has_field?("faq-translation-domanda", with: @edited_question, wait: 5), "La domanda base non e' visibile nell'editor traduzioni")
    assert_record(has_field?("faq-translation-risposta", with: @edited_answer, wait: 5), "La risposta base non e' visibile nell'editor traduzioni")
    assert_record(domanda_field.value == @edited_question, "La domanda base non e' stata caricata nell'editor traduzioni")
    assert_record(risposta_field.value == @edited_answer, "La risposta base non e' stata caricata nell'editor traduzioni")

    page.execute_script(
      <<~JS,
        const [question, answer] = arguments
        const domandaField = document.getElementById("faq-translation-domanda")
        const rispostaField = document.getElementById("faq-translation-risposta")

        domandaField.value = question
        domandaField.dispatchEvent(new Event("input", { bubbles: true }))
        domandaField.dispatchEvent(new Event("change", { bubbles: true }))

        rispostaField.value = answer
        rispostaField.dispatchEvent(new Event("input", { bubbles: true }))
        rispostaField.dispatchEvent(new Event("change", { bubbles: true }))
      JS
      @translated_question,
      @translated_answer
    )

    assert_record(has_field?("faq-translation-domanda", with: @translated_question, wait: 5), "La domanda tradotta non e' stata inserita nell'editor")
    assert_record(has_field?("faq-translation-risposta", with: @translated_answer, wait: 5), "La risposta tradotta non e' stata inserita nell'editor")
    click_button("Salva traduzione")
  end

  page.assert_selector("#faq-translations-modal", visible: false, wait: 5)
  page.assert_text("FAQ Management", wait: 5)

  deadline = Time.now + 10
  @translation = nil

  while Time.now < deadline
    @translation = FaqTranslation.find_by(faq_id: @faq.id, locale: "en")
    break if @translation.present? &&
      @translation.domanda.to_s.strip == @translated_question &&
      @translation.risposta.to_s.strip == @translated_answer

    sleep 0.1
  end

  assert_record(@translation.present?, "Traduzione inglese non creata")
  assert_record(@translation.domanda.to_s.strip == @translated_question, "Domanda tradotta non corretta")
  assert_record(@translation.risposta.to_s.strip == @translated_answer, "Risposta tradotta non corretta")
end

Quando("il visitatore consulta, filtra, cambia lingua e cerca la FAQ") do
  Capybara.reset_sessions!
  visit "/visitors/faqs"

  page.assert_text("Visitatore", wait: 5)
  page.assert_selector(".faq-card", text: @edited_question, wait: 5)
  page.assert_selector(".faq-card", text: @distractor_question, wait: 5)

  find("#faq-filter-visitor").click
  within("ul[aria-labelledby='faq-filter-visitor']") do
    click_button(@category)
  end

  page.assert_text("Categoria: #{@category}", wait: 5)
  page.assert_selector(".faq-card", text: @edited_question, wait: 5)
  page.assert_no_selector(".faq-card", text: @distractor_question, wait: 5)

  find("#faq-lang-visitor").click
  within("ul[aria-labelledby='faq-lang-visitor']") do
    click_link("English", exact: false)
  end

  page.assert_text("Lingua: English", wait: 5)
  page.assert_selector(".faq-card", text: @translated_question, wait: 5)
  page.assert_selector(".faq-card", text: @translated_answer, wait: 5)

  find("button[data-bs-target='#faq-search-visitor']").click
  page.assert_selector("#faq-search-visitor.show", visible: :all, wait: 5)

  within("#faq-search-visitor.show") do
    fill_in("q", with: "new badge")
    click_button("Cerca")
  end

  page.assert_selector(".faq-card", text: @translated_question, wait: 5)
  page.assert_no_selector(".faq-card", text: @distractor_question, wait: 5)
end

Quando("l'utente registrato vota la FAQ") do
  login_as(@user, redirect_to: "/user/faqs?locale=en")

  page.assert_text("Utente registrato", wait: 5)
  page.assert_text(@translated_question, wait: 5)
  page.assert_text("Accettata", wait: 5)

  within(".faq-card", text: @translated_question) do
    page.assert_selector("[data-faqs-votes-target='upCount']", text: "0", wait: 5)
    page.assert_selector("[data-faqs-votes-target='downCount']", text: "0", wait: 5)

    find("button[title='Pollice in su']").click
    page.assert_selector("[data-faqs-votes-target='upCount']", text: "1", wait: 5)

    find("button[title='Pollice in giù']").click
    page.assert_selector("[data-faqs-votes-target='upCount']", text: "0", wait: 5)
    page.assert_selector("[data-faqs-votes-target='downCount']", text: "1", wait: 5)
  end

  @vote = FaqVote.find_by(faq: @faq, user: @user)
  assert_record(@vote.present?, "Il voto FAQ non e' stato salvato")
  assert_record(@vote.value == -1, "Il voto finale atteso e' pollice in giu'")
end

Quando("l'amministratore elimina la FAQ") do
  login_as(@admin, redirect_to: "/admin/faqs?locale=it")

  within(".faq-card", text: @edited_question) do
    find("button[title='Elimina FAQ']").click
  end

  page.assert_selector("#faqs-dialog-modal.show", wait: 5)

  page.execute_script(
    "arguments[0].submit()",
    find("form[action='/faqs/#{@faq.id}']", visible: :all).native
  )

  page.assert_no_text(@edited_question, wait: 5)
end

Allora("la FAQ del flusso non è più disponibile e la FAQ aggiuntiva resta visibile ai visitatori") do
  assert_record(!Faq.exists?(@faq.id), "La FAQ eliminata e' ancora presente")
  assert_record(FaqTranslation.find_by(id: @translation.id).nil?, "La traduzione eliminata e' ancora presente")
  assert_record(FaqVote.find_by(id: @vote.id).nil?, "Il voto eliminato e' ancora presente")

  visit "/visitors/faqs?locale=en"

  page.assert_no_selector(".faq-card", text: @translated_question, wait: 5)
  page.assert_selector(".faq-card", text: @distractor_question, wait: 5)
end
