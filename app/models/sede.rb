class Sede < ApplicationRecord
    self.table_name = "sedi"
    validates :nome, :indirizzo, :latitudine, :longitudine, presence: true
    validates :edifici, presence: true
    validates :latitudine, :longitudine, numericality:true
end
