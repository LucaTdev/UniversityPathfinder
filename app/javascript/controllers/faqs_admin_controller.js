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
    const catSelect = document.getElementById('faq_faq_category_id');
    if (catSelect) catSelect.selectedIndex = 0;
  }
  
  openEditForm(event) {
    // Prendi i parametri dall'evento
    const faqId = event.params.faqId;
    const domanda = event.params.domanda;
    const risposta = event.params.risposta;
    const faqCategoryId = event.params.faqCategoryId;
    
    document.getElementById('faq-form').style.display = 'block';
    document.getElementById('form-title').textContent = 'Modifica FAQ';
    document.getElementById('submit-btn').textContent = 'Aggiorna FAQ';
    
    // Setup form per modifica
    document.getElementById('faq-form-element').action = '/faqs/' + faqId;
    document.getElementById('form-method').value = 'patch';
    document.getElementById('faq_domanda').value = domanda;
    document.getElementById('faq_risposta').value = risposta;
    const catSelect = document.getElementById('faq_faq_category_id');
    if (catSelect) {
      if (faqCategoryId) {
        catSelect.value = faqCategoryId;
      } else {
        catSelect.selectedIndex = 0;
      }
    }
  }
  
  closeForm() {
    document.getElementById('faq-form').style.display = 'none';
    // Reset form
    document.getElementById('faq-form-element').reset();
  }
}
