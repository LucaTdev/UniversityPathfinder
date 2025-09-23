import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  openAddForm() {
    document.getElementById('faq-form').style.display = 'block';
    document.getElementById('form-title').textContent = 'Nuova FAQ';
    document.getElementById('submit-btn').textContent = 'Salva FAQ';
    
    // Reset form per aggiunta
    document.getElementById('faq-form-element').action = '/faqs';
    document.getElementById('form-method').value = '';
    document.getElementById('faq_domanda').value = '';
    document.getElementById('faq_risposta').value = '';
    document.getElementById('faq_categoria').value = '';
  }
  
  openEditForm(event) {
    // Prendi i parametri dall'evento
    const faqId = event.params.faqId;
    const domanda = event.params.domanda;
    const risposta = event.params.risposta;
    const categoria = event.params.categoria;
    
    document.getElementById('faq-form').style.display = 'block';
    document.getElementById('form-title').textContent = 'Modifica FAQ';
    document.getElementById('submit-btn').textContent = 'Aggiorna FAQ';
    
    // Setup form per modifica
    document.getElementById('faq-form-element').action = '/faqs/' + faqId;
    document.getElementById('form-method').value = 'patch';
    document.getElementById('faq_domanda').value = domanda;
    document.getElementById('faq_risposta').value = risposta;
    document.getElementById('faq_categoria').value = categoria;
  }
  
  closeForm() {
    document.getElementById('faq-form').style.display = 'none';
    // Reset form
    document.getElementById('faq-form-element').reset();
  }
}