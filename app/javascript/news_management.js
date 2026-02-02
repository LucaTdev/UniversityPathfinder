document.addEventListener('DOMContentLoaded', function() {
  const newsModal = new bootstrap.Modal(document.getElementById('newsModal'));
  const newsForm = document.getElementById('news-form');
  const saveBtn = document.getElementById('save-news-btn');
  const addBtn = document.getElementById('add-news-btn');
  
  // Aggiungi nuova news
  addBtn.addEventListener('click', function() {
    resetForm();
    document.getElementById('newsModalLabel').textContent = 'Nuova News';
    newsModal.show();
  });
  
  
    document.getElementById('news-icon').addEventListener('change', function() {
        document.getElementById('news-icon-custom').value = this.value;
    });

    document.getElementById('news-icon-custom').addEventListener('input', function() {
        const select = document.getElementById('news-icon');
        const option = Array.from(select.options).find(opt => opt.value === this.value);
        if (option) {
            select.value = this.value;
        }
    });

  // Salva news (create o update)
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
    
    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
      if (result.success) {
        if (newsId) {
          // Update existing
          const existingItem = document.querySelector(`[data-news-id="${newsId}"]`);
          existingItem.outerHTML = result.news;
        } else {
          // Add new
          const container = document.getElementById('news-container');
          container.insertAdjacentHTML('afterbegin', result.news);
        }
        
        updateNewsCount();
        newsModal.hide();
        resetForm();
      } else {
        alert('Errore: ' + result.errors.join(', '));
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('Errore durante il salvataggio');
    });
  });
  
  // Edit news (delegated event)
  document.addEventListener('click', function(e) {
    if (e.target.closest('.edit-news-btn')) {
      const btn = e.target.closest('.edit-news-btn');
      const newsId = btn.dataset.newsId;
      const newsItem = document.querySelector(`[data-news-id="${newsId}"]`);
      
      // Popola il form con i dati esistenti
      document.getElementById('news-id').value = newsId;
      document.getElementById('news-title').value = newsItem.querySelector('h6').textContent;
      document.getElementById('news-content').value = newsItem.querySelector('p').textContent;
      document.getElementById('news-category').value = newsItem.querySelector('.badge-custom').textContent.trim();
      document.getElementById('news-icon').value = newsItem.querySelector('.news-icon i').className;
      
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
      
      fetch(`/news/${newsId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      .then(response => response.json())
      .then(result => {
        if (result.success) {
          document.querySelector(`[data-news-id="${newsId}"]`).remove();
          updateNewsCount();
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('Errore durante l\'eliminazione');
      });
    }
  });
  
  function resetForm() {
    newsForm.reset();
    document.getElementById('news-id').value = '';
  }
  
  function updateNewsCount() {
    const count = document.querySelectorAll('.news-item').length;
    document.getElementById('news-count').textContent = `${count} nuove`;
  }
});