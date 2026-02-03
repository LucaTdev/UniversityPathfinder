document.addEventListener('DOMContentLoaded', function() {
  // Verifica se l'utente è admin
  const newsContainer = document.getElementById('news-container');
  const isAdmin = newsContainer?.dataset.isAdmin === 'true';
  
  console.log('Is Admin:', isAdmin); // Debug
  
  if (!isAdmin) {
    console.log('Utente non admin - funzionalità di modifica disabilitate');
    // Non caricare nessuna funzionalità di modifica
    return;
  }
  
  // Da qui in poi, solo gli admin arrivano
  console.log('Caricamento funzionalità admin...');
  
  // Verifica che Bootstrap sia caricato
  if (typeof bootstrap === 'undefined') {
    console.error('Bootstrap non è caricato!');
    return;
  }

  const newsModalElement = document.getElementById('newsModal');
  if (!newsModalElement) {
    console.error('Modal non trovato! (Normale se non sei admin)');
    return;
  }

  const newsModal = new bootstrap.Modal(newsModalElement);
  const newsForm = document.getElementById('news-form');
  const saveBtn = document.getElementById('save-news-btn');
  const addBtn = document.getElementById('add-news-btn');
  
  // Ottieni il CSRF token
  const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
  if (!csrfToken) {
    console.error('CSRF token non trovato!');
  }
  
  // Aggiungi nuova news
  if (addBtn) {
    addBtn.addEventListener('click', function() {
      console.log('Apertura modal per nuova news');
      resetForm();
      document.getElementById('newsModalLabel').textContent = 'Nuova News';
      newsModal.show();
    });
  }
  
  // Salva news (create o update)
  if (saveBtn) {
    saveBtn.addEventListener('click', function() {
      const newsId = document.getElementById('news-id').value;
      const formData = new FormData(newsForm);
      
      const data = {
        news: {
          title: formData.get('title'),
          content: formData.get('content'),
          category: formData.get('category'),
          icon_class: formData.get('icon_class') || 'fas fa-newspaper'
        }
      };
      
      const url = newsId ? `/news/${newsId}` : '/news';
      const method = newsId ? 'PATCH' : 'POST';
      
      console.log('Invio richiesta:', { url, method, data });
      
      fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify(data)
      })
      .then(response => {
        console.log('Response status:', response.status);
        
        if (response.status === 403) {
          throw new Error('Non hai i permessi per eseguire questa azione');
        }
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(result => {
        console.log('Risultato:', result);
        
        if (result.success) {
          if (newsId) {
            // Update existing
            const existingItem = document.querySelector(`[data-news-id="${newsId}"]`);
            if (existingItem) {
              existingItem.outerHTML = result.news;
            }
          } else {
            // Add new
            const container = document.getElementById('news-container');
            container.insertAdjacentHTML('afterbegin', result.news);
          }
          
          updateNewsCount();
          newsModal.hide();
          resetForm();
          
          showAlert('News salvata con successo!', 'success');
        } else {
          showAlert('Errore: ' + (result.errors?.join(', ') || 'Errore sconosciuto'), 'danger');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        showAlert('Errore: ' + error.message, 'danger');
      });
    });
  }
  
  // Edit news (delegated event)
  document.addEventListener('click', function(e) {
    if (e.target.closest('.edit-news-btn')) {
      const btn = e.target.closest('.edit-news-btn');
      const newsId = btn.dataset.newsId;
      const newsItem = document.querySelector(`[data-news-id="${newsId}"]`);
      
      if (!newsItem) return;
      
      console.log('Modifica news:', newsId);
      
      document.getElementById('news-id').value = newsId;
      document.getElementById('news-title').value = newsItem.querySelector('h6')?.textContent || '';
      document.getElementById('news-content').value = newsItem.querySelector('p')?.textContent || '';
      document.getElementById('news-category').value = newsItem.querySelector('.badge-custom')?.textContent.trim() || '';
      document.getElementById('news-icon').value = newsItem.querySelector('.news-icon i')?.className || '';
      
      document.getElementById('newsModalLabel').textContent = 'Modifica News';
      newsModal.show();
    }
  });
  
  // Delete news (delegated event)
  document.addEventListener('click', function(e) {
    if (e.target.closest('.delete-news-btn')) {
      if (!confirm('Sei sicuro di voler eliminare questa news?')) return;
      
      const btn = e.target.closest('.delete-news-btn');
      const newsId = btn.dataset.newsId;
      
      console.log('Elimina news:', newsId);
      
      fetch(`/news/${newsId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        }
      })
      .then(response => {
        if (response.status === 403) {
          throw new Error('Non hai i permessi per eseguire questa azione');
        }
        return response.json();
      })
      .then(result => {
        if (result.success) {
          const newsItem = document.querySelector(`[data-news-id="${newsId}"]`);
          if (newsItem) {
            newsItem.remove();
          }
          updateNewsCount();
          showAlert('News eliminata con successo!', 'success');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        showAlert('Errore: ' + error.message, 'danger');
      });
    }
  });
  
  function resetForm() {
    if (newsForm) {
      newsForm.reset();
      document.getElementById('news-id').value = '';
    }
  }
  
  function updateNewsCount() {
    const count = document.querySelectorAll('.news-item').length;
    const countElement = document.getElementById('news-count');
    if (countElement) {
      countElement.textContent = `${count} nuove`;
    }
  }
  
  function showAlert(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    alertDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    document.body.appendChild(alertDiv);
    
    setTimeout(() => {
      alertDiv.remove();
    }, 3000);
  }
});