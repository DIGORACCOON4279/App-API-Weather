# Weather App

require 'sinatra'
require 'open-uri'
require 'json'

set :port, ENV['PORT'] || 4567  # Render utilizará el puerto especificado por la variable de entorno

# Tu API Key
API_KEY = 'b057e136c8094a1fbc100414242212'

# Ruta principal para mostrar el formulario
get '/' do
  erb :index
end

# Ruta para manejar la búsqueda de ciudad
get '/clima' do
  ciudad = params['ciudad']

  # Verificar que el nombre de la ciudad no esté vacío
  if ciudad.nil? || ciudad.strip.empty?
    @error = "Por favor, ingresa el nombre de una ciudad."
    return erb :index
  end

  # URL de la API
  url = "https://api.weatherapi.com/v1/current.json?key=#{API_KEY}&q=#{ciudad}"

  begin
    # Realizar la solicitud a la API
    response = URI.open(url).read
    data = JSON.parse(response)

    # Estructurar los datos a mostrar
    @weather = {
      city: data['location']['name'],
      temp: data['current']['temp_c'],
      condition: data['current']['condition']['text'],
      wind: data['current']['wind_kph'],
      humidity: data['current']['humidity'],
      feels_like: data['current']['feelslike_c']
    }

    # Asignar la imagen dependiendo de la condición climática
    case @weather[:condition].downcase
    when /sunny|clear/
      @weather[:image] = '/images/sunny.gif'
    when /rain|showers|storm/
      @weather[:image] = '/images/stormy.gif'
    when /snow|flurries/
      @weather[:image] = '/images/snowy.gif'
    else
      @weather[:image] = '/images/cloudy.gif' # Imagen para condiciones nubladas
    end

    erb :index
  rescue => e
    @error = "No se pudo obtener el clima para la ciudad #{ciudad}. Error: #{e.message}"
    erb :index
  end
end
