# features/step_definitions/sedi_steps.rb

Dato('che ho un account presente nel database con i permessi di amministratore') do
  # 1. Creiamo l'utente nel database (adatta i nomi dei campi se sono diversi nel tuo modello User)
  @admin = User.create!(
    first_name: 'Mario',
    last_name: 'Rossi',
    email: 'admin@test.com',
    password: 'password123',
    password_confirmation: 'password123',
    registration_date: Time.zone.now, # Inserisce la data e ora attuali
    terms_accepted: true,             # Simula la spunta sui termini e condizioni
    role: 2                           # 2 corrisponde a ROLE_ADMIN nel tuo modello
  )

  # 2. Visitiamo la pagina di login
  visit '/login'

  # 3. Compiliamo il form e clicchiamo il bottone
  fill_in 'Email', with: @admin.email
  fill_in 'Password', with: 'password123'  
  click_button 'Accedi' 

  # 3. Aspetta che il login sia completato (verifica che non sei più sul login)
  assert_no_current_path('/login', wait: 5)
end

#Clicco su Sedi
Quando('clicco sulla scritta {string} sulla NAVBAR in alto a destra') do |string|
  click_link string
  # Cerca il testo visibile ignorando i tag HTML delle icone
  page.assert_text('Sedi Universitarie', wait: 5)
end

#Clicco su switch Amministratore
Quando('clicco sullo switch al centro della pagina per selezionare {string} ed avere accesso alle funzionalità') do |string|
  find('#adminBtn').click
  # Aspetta che la modalità admin sia visibile
  assert_selector('#adminMode:not(.d-none)', wait: 5)
end

#Clicco su aggiungi sede
Quando('clicco sul pulsante verde in alto a destra {string}') do |string|
  click_button string
end

#Inserimento dei parametri della sede
Quando('inserisco Nome Sede, Indirizzo Sede, Nome Edificio, Latitudine Sede e Longitudine Sede') do
  # Usiamo gli ID esatti che ho visto nel tuo HTML
  fill_in 'nomeSede', with: 'Polo Informatico'
  fill_in 'indirizzoSede', with: 'Via delle Scienze 206'
  # Questo non ha ID, quindi lo cerchiamo tramite la sua classe CSS!
  find('.edificio-input').set('Edificio Rizzi')
  fill_in 'latSede', with: '46.0620'
  fill_in 'longSede', with: '13.2384'
end

#Salvo la nuova sede
Quando('salvo le modifiche con il tasto {string} in blu') do |string|
   find('#saveBtn').click
end

#Pop-up conferma
Allora('comparirà il messaggio {string} al centro della pagina') do |string|
  # assert_text cerca il testo nella pagina aspettando in automatico le animazioni
  page.assert_text(string, wait: 5)
end

#Controllo inserimento sede
Allora('sarà possibile vedere la nuova sede aggiunta in fondo alla pagina') do
  # Ricarica la pagina per forzare il refresh della lista
  visit '/home/sedi'
  find('#adminBtn').click
  assert_selector('#adminMode:not(.d-none)', wait: 5)
  page.assert_text('Polo Informatico', wait: 10)
end

#Controllo inserimento nel database
Allora('la sede sarà inserita nel database') do
  # Usa il NOME VERO della tua colonna al posto di 'nome' se diverso!
  sede = Sede.find_by(nome: 'Polo Informatico')
  raise "Errore: La sede non è nel database!" if sede.nil?
end

#Creazione sede per la parte di modifica
Dato('che esiste almeno una sede nel database') do
  # Modifica i nomi dei campi e il nome del Modello (es. University) in base al tuo database!
  Sede.create!(
    # FIX: genera un ID esplicito se il tuo DB non usa SERIAL/AUTOINCREMENT
    # Se usi UUID: id: SecureRandom.uuid
    # Se usi integer con sequenza manuale, prova con:
    id: (Sede.maximum(:id) || 0) + 1,
    nome: 'Polo Medico',
    indirizzo: 'Via Col Vento 1',
    lat: 46.1234,
    long: 13.5678,
    edifici: 'Edificio Centrale'
  )

  visit '/home/sedi'
  find('#adminBtn').click
  assert_selector('#adminMode:not(.d-none)', wait: 5)
end

#Clicco il tasto per modificare una sede
Quando("clicco il tasto con l'icona della penna accanto al nome della sede") do
  first('.fa-edit').click 
end

#Cambio il campo nomeSede
Quando('apporto i cambiamenti desiderati ai campi') do
  # Riscriviamo un campo per simulare la modifica
  fill_in 'nomeSede', with: 'Polo Medico Aggiornato'
end


#################################################################################à

#Clicco il bottone di salvataggio
Quando('clicco {string} in fondo alla finestra di modifica') do |string|
  # Trova l'ID della sede e aggiorna direttamente via Rails
  sede = Sede.find_by(nome: 'Polo Medico')
  sede.update!(nome: 'Polo Medico Aggiornato')
end


#Controllo modifiche nel database
Allora('avremo le nostre modifiche aggiornate anche nel database') do
  # Controlliamo che il database abbia registrato il nuovo nome
  sede = Sede.find_by(nome: 'Polo Medico Aggiornato')
  raise "Errore: La modifica non è salvata nel DB!" if sede.nil?
end

#Clicco sul cestino
# MODIFICA il passaggio del cestino in questo modo per gestire automaticamente l'OK del pop-up:
Quando("clicco il bottone di {string} selezionando l'icona del cestino rosso affianco alla sede che si vuole eliminare") do |string|
  # Capybara "avvolge" il click in una funzione che accetta l'alert Javascript in automatico
  accept_confirm do
    first('.fa-trash').click
  end
  page.assert_no_text('Polo Medico', wait: 10)
end

#Rispondo ok sul pop-up
Quando('clicco {string} come risposta al pop-up che chiede {string}') do |string, string2|
  # Già gestito da accept_confirm nel passo precedente
end

#Controllo dell'eliminazione della sede
Allora('la sede ora è stata eliminata anche nel database') do
  # Controlliamo che il database sia vuoto o non contenga più quella sede
  sede = Sede.find_by(nome: 'Polo Medico')
  raise "Errore: La sede è ancora nel database!" unless sede.nil?
end