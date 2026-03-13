# features/step_definitions/sedi_steps.rb

Quando("clicco sul pulsante verde in alto a destra {string}") do |nome_bottone|
  # Capybara cercherà un bottone o un link con quel nome e lo cliccherà
  click_link_or_button nome_bottone
end

Quando("inserisco Nome Sede, Indirizzo Sede, Nome Edificio, Latitudine Sede e Longitudine Sede") do
  # Capybara compilerà i campi del modulo
  fill_in 'Nome Sede', with: 'Sede Centrale'
  fill_in 'Indirizzo Sede', with: 'Via Roma 1'
  # ... e così via per gli altri campi
end

Allora("comparirà il messaggio {string} al centro della pagina") do |messaggio|
  # Verifica che il testo sia presente nella pagina
  expect(page).to have_content(messaggio)
end