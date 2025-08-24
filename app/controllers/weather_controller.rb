class WeatherController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def show
    lat = params[:lat]
    lon = params[:lon]

    if lat.blank? || lon.blank?
      return render json: { error: 'Latitudine e longitudine richieste' }, status: 400
    end

    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current_weather=true")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    if data['current_weather']
      render json: {
        temperature: data['current_weather']['temperature'],
        windspeed:   data['current_weather']['windspeed'],
        time:        data['current_weather']['time']
      }
    else
      render json: { error: 'Nessun dato meteo' }, status: 404
    end
  end
end
