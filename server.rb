require "sinatra"
require_relative "./database"
require_relative "./telegram_handler"

class Protected < Sinatra::Base

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'admin' && password == ENV["ADMIN_PASSWORD"]
  end

  get '/' do
    erb :admin_message
  end

  post '/' do
    success_count, error_count = Mood::TelegramHandler.send_message(
      message: params[:message]
    )
    
    erb :admin_message, :locals => {'message' => "#{success_count} messages sent successfully. #{error_count} messages failed to be sent."}
  end

end

class Public < Sinatra::Base

  get '/' do
    "oh hai there"
  end

end
