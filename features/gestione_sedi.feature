# language: it

Funzionalità: Gestione delle Sedi Universitarie
  Come amministratore del sistema
  Voglio poter aggiungere, modificare ed eliminare le sedi

  Contesto: (Passaggi 1-3)
    Dato che ho un account presente nel database con i permessi di amministratore
    Quando clicco sulla scritta "Sedi" sulla NAVBAR in alto a destra
    E clicco sullo switch al centro della pagina per selezionare "Amministratore" ed avere accesso alle funzionalità

  Scenario: Aggiunta di una nuova sede (Passaggi 4-7)
    Quando clicco sul pulsante verde in alto a destra "Aggiungi Sede"
    E inserisco Nome Sede, Indirizzo Sede, Nome Edificio, Latitudine Sede e Longitudine Sede
    E salvo le modifiche con il tasto "Salva Sede" in blu
    Allora comparirà il messaggio "Successo! Sede universitaria aggiunta!" al centro della pagina
    E sarà possibile vedere la nuova sede aggiunta in fondo alla pagina
    E la sede sarà inserita nel database

  Scenario: Modifica di una sede esistente (Passaggi 8-11)
    Dato che esiste almeno una sede nel database
    Quando clicco il tasto con l'icona della penna accanto al nome della sede
    E apporto i cambiamenti desiderati ai campi
    E clicco "Aggiorna Sede" in fondo alla finestra di modifica
    Allora comparirà a schermo "Successo! Sede universitaria aggiornata!"
    E avremo le nostre modifiche aggiornate anche nel database

  Scenario: Eliminazione di una sede (Passaggi 12-14)
    Dato che esiste almeno una sede nel database
    Quando clicco il bottone di "Elimina Sede" selezionando l'icona del cestino rosso affianco alla sede che si vuole eliminare
    E clicco "Ok" come risposta al pop-up che chiede "Sei sicuro di voler eliminare questa sede universitaria?"
    Allora la sede ora è stata eliminata anche nel database