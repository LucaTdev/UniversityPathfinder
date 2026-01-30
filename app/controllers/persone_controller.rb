class PersoneController < ApplicationController
    def new
      @persona = Persona.new
    end
  
    def create
      @persona = Persona.new(persona_params)
      if @persona.save
        # Non facciamo redirect, basta conferma
        render plain: "Persona salvata con successo!"
      else
        render plain: "Errore: ricontrolla i campi.", status: :unprocessable_entity
      end
    end
  
    private
  
    def persona_params
      params.require(:persona).permit(:id, :nome, :cognome, :nascita)
    end
  end
  