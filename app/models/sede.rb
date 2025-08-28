class Sede < ApplicationRecord
    self.table_name = "sedi"
    validates :nome, :indirizzo, presence: true
    validates :edifici, presence: true
end
