class Faq < ApplicationRecord
    validates :domanda, presence: true
    validates :risposta, presence: true
    validates :categoria, presence: true
  end
  