# language: it

@javascript
Funzionalità: Gestione FAQ end-to-end
  Per verificare il flusso principale delle FAQ
  Come team di sviluppo
  Voglio eseguire uno scenario completo dal suggerimento alla consultazione finale

  Contesto:
    Dato che esistono un utente registrato e un amministratore per il flusso FAQ
    E esiste una FAQ aggiuntiva per verificare filtro e ricerca

  Scenario: Suggerimento utente e pubblicazione della FAQ
    Quando l'utente registrato accede alla sua area FAQ e invia un suggerimento
    E l'amministratore pubblica il suggerimento come FAQ
    Allora l'utente registrato vede la notizia di pubblicazione

  Scenario: Aggiornamento della FAQ e notifica all'utente
    Dato che esiste una FAQ pubblicata nel flusso FAQ
    Quando l'amministratore modifica la FAQ pubblicata
    Allora l'utente registrato vede la notizia di aggiornamento

  Scenario: Traduzione inglese e consultazione lato visitatore
    Dato che esiste una FAQ aggiornata nel flusso FAQ
    Quando l'amministratore aggiunge una traduzione inglese alla FAQ
    Allora il visitatore consulta, filtra, cambia lingua e cerca la FAQ

  Scenario: Voto dell'utente e rimozione finale della FAQ
    Dato che esiste una FAQ tradotta nel flusso FAQ
    Quando l'utente registrato vota la FAQ
    E l'amministratore elimina la FAQ
    Allora la FAQ del flusso non è più disponibile e la FAQ aggiuntiva resta visibile ai visitatori
