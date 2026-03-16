require "application_system_test_case"

class FaqsTest < ApplicationSystemTestCase
  self.fixture_table_names = []

  setup do
    token = SecureRandom.hex(4)

    @user = User.create!(
      first_name: "Test",
      last_name: "User",
      email: "faq-user-#{token}@example.com",
      password: "password123",
      password_confirmation: "password123",
      registration_date: Date.current,
      role: User::ROLE_STUDENT,
      terms_accepted: true
    )

    @admin = User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "faq-admin-#{token}@example.com",
      password: "password123",
      password_confirmation: "password123",
      registration_date: Date.current,
      role: User::ROLE_ADMIN,
      terms_accepted: true
    )
  end

  test "registered user submits a suggestion and admin publishes it as faq" do
    token = SecureRandom.hex(4)
    question = "Come recupero il badge universitario? #{token}"
    details = "Ho smarrito il badge e devo richiederne uno nuovo. #{token}"
    answer = "Recati in segreteria con un documento e richiedi il duplicato. #{token}"
    category = "Segreteria #{token}"
    translated_question = "How do I recover my university badge? #{token}"
    translated_answer = "Go to the student office with an ID and request a duplicate badge. #{token}"

    visit test_login_path(user_id: @user.id, redirect_to: user_faqs_path)

    assert_current_path user_faqs_path
    assert_text "Utente registrato"
    assert_text @user.first_name
    assert_button "Suggerisci FAQ"

    click_button "Suggerisci FAQ"

    assert_selector "#suggest-faq-form.show"

    within "#suggest-faq-form" do
      assert_field "suggest_domanda"
      assert_field "suggest_dettagli"
      assert_field "suggest_risposta"
      assert_field "suggest_categoria"

      fill_in "suggest_domanda", with: question
      fill_in "suggest_dettagli", with: details
      fill_in "suggest_risposta", with: answer
      fill_in "suggest_categoria", with: category
    end

    assert_difference("FaqSuggestion.count", 1) do
      click_button "Invia suggerimento"
      assert_current_path user_faqs_path
    end

    suggestion = FaqSuggestion.order(:id).last

    assert_equal @user.id, suggestion.user_id
    assert_equal question, suggestion.domanda
    assert_equal details, suggestion.dettagli
    assert_equal answer, suggestion.risposta
    assert_equal category, suggestion.categoria
    assert suggestion.attesa?

    assert_text "I tuoi suggerimenti"
    assert_text question
    assert_text category
    assert_text "In attesa"

    visit test_login_path(user_id: @admin.id, redirect_to: admin_faqs_path)

    assert_current_path admin_faqs_path
    assert_text "Amministrazione FAQ"
    assert_text "Suggerimento ##{suggestion.id}"

    publish_form_selector = "form[action='#{publish_admin_faq_suggestion_path(suggestion)}']"
    assert_selector publish_form_selector

    assert_difference("Faq.count", 1) do
      assert_difference("FaqCategory.count", 1) do
        within publish_form_selector do
          fill_in "publish_categoria", with: category
          fill_in "publish_domanda", with: question
          fill_in "publish_risposta", with: answer
          click_button "Pubblica come FAQ"
        end

        assert_current_path admin_faqs_path
      end
    end

    suggestion.reload
    faq = suggestion.faq

    assert suggestion.accettata?
    assert_not_nil faq
    assert_equal question, faq.domanda
    assert_equal answer, faq.risposta
    assert_equal category, faq.categoria
    assert_equal category, suggestion.categoria
    assert_equal faq.id, suggestion.faq_id
    assert_equal category, suggestion.faq_category.name

    visit admin_faqs_path

    assert_text "Amministrazione FAQ"
    assert_text question
    assert_text answer
    assert_text category
    assert_no_text "Suggerimento ##{suggestion.id}"

    within(".faq-card", text: question) do
      find("button[title='Traduzioni']").click
    end

    assert_selector "#faq-translations-modal.show"

    within "#faq-translations-modal" do
      assert_text "Traduzioni FAQ"
      assert_text question

      english_row = find(".list-group-item", text: "English")
      english_row.find("button[title='Aggiungi traduzione']").click

      assert_field "faq-translation-domanda", with: question
      assert_field "faq-translation-risposta", with: answer

      fill_in "faq-translation-domanda", with: translated_question
      fill_in "faq-translation-risposta", with: translated_answer

      click_button "Salva traduzione"
    end

    assert_selector "#faq-translations-modal", visible: false
    assert_text "FAQ Management"

    faq.reload
    translation = faq.translation_for("en")

    assert_not_nil translation
    assert_equal "en", translation.locale
    assert_equal translated_question, translation.domanda
    assert_equal translated_answer, translation.risposta

    within(".faq-card", text: question) do
      find("button[title='Traduzioni']").click
    end

    assert_selector "#faq-translations-modal.show"

    within "#faq-translations-modal" do
      english_row = find(".list-group-item", text: "English")
      assert_text "Tradotta"
      english_row.find("button[title='Modifica traduzione']")
    end

    distractor_question = "Come prenoto un'aula studio? #{token}"
    distractor_answer = "Usa il portale prenotazioni dell'ateneo. #{token}"
    distractor_faq = Faq.create!(
      domanda: distractor_question,
      risposta: distractor_answer,
      faq_category: FaqCategory.general!
    )

    visit visitor_faqs_path

    assert_current_path visitor_faqs_path
    assert_text "Visitatore"
    assert_selector ".faq-card", minimum: 2
    assert_selector ".faq-card", text: question
    assert_selector ".faq-card", text: answer
    assert_selector ".faq-card", text: distractor_question
    assert_selector ".faq-card", text: distractor_answer

    find("#faq-filter-visitor").click

    within("ul[aria-labelledby='faq-filter-visitor']") do
      click_button category
    end

    assert_text "Categoria: #{category}"
    assert_selector ".faq-card", text: question
    assert_no_selector ".faq-card", text: distractor_question

    find("#faq-lang-visitor").click

    within("ul[aria-labelledby='faq-lang-visitor']") do
      click_link "English", exact: false
    end

    assert_text "Lingua: English"
    assert_selector ".faq-card", text: translated_question
    assert_selector ".faq-card", text: translated_answer
    assert_no_text question

    click_button "Cerca FAQ"

    within "#faq-search-visitor" do
      fill_in "q", with: "duplicate badge"
      click_button "Cerca"
    end

    assert_current_path visitor_faqs_path(locale: "en", q: "duplicate badge")
    assert_selector ".faq-card", text: translated_question
    assert_selector ".faq-card", text: translated_answer
    assert_no_selector ".faq-card", text: distractor_question

    visit test_login_path(user_id: @user.id, redirect_to: user_faqs_path(locale: "en"))

    assert_current_path user_faqs_path(locale: "en")
    assert_text "Utente registrato"
    assert_text question
    assert_text "Accettata"

    within ".faq-card", text: translated_question do
      assert_selector "[data-faqs-votes-target='upCount']", text: "0"
      assert_selector "[data-faqs-votes-target='downCount']", text: "0"
      assert_selector "button.btn-outline-success[title='Pollice in su']"
      assert_selector "button.btn-outline-danger[title='Pollice in giù']"

      find("button[title='Pollice in su']").click

      assert_selector "[data-faqs-votes-target='upCount']", text: "1"
      assert_selector "[data-faqs-votes-target='downCount']", text: "0"
      assert_selector "button.btn-success[title='Pollice in su']"
      assert_selector "button.btn-outline-danger[title='Pollice in giù']"

      find("button[title='Pollice in giù']").click

      assert_selector "[data-faqs-votes-target='upCount']", text: "0"
      assert_selector "[data-faqs-votes-target='downCount']", text: "1"
      assert_selector "button.btn-outline-success[title='Pollice in su']"
      assert_selector "button.btn-danger[title='Pollice in giù']"
    end

    vote = FaqVote.find_by!(faq: faq, user: @user)
    assert_equal(-1, vote.value)
    assert_equal 0, FaqVote.where(faq: faq, value: 1).count
    assert_equal 1, FaqVote.where(faq: faq, value: -1).count

    distractor_faq.destroy!
  end
end
