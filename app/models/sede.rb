class Sede < ApplicationRecord
    self.table_name = "sedi"
    validates :nome, :indirizzo, :lat, :long, presence: true
    validates :edifici, presence: true
end
