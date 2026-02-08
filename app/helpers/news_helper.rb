module NewsHelper
  def category_color(category)
    colors = {
      'Università' => '#6c5ce7',
      'Locale' => '#74b9ff',
      'Sport' => '#00b894',
      'Economia' => '#636e72',
      'Ambiente' => '#00cec9'
    }
    colors[category] || '#666'
  end
  
  def category_icon(category)
    icons = {
      'Università' => 'fas fa-graduation-cap',
      'Locale' => 'fas fa-city',
      'Sport' => 'fas fa-futbol',
      'Economia' => 'fas fa-chart-line',
      'Ambiente' => 'fas fa-leaf'
    }
    icons[category] || 'fas fa-newspaper'
  end
end